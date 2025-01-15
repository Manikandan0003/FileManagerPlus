//
//  DocumentListView.swift
//  FileManagerPlus
//
//  Created by MANIKANDAN on 15/01/25.
//

import SwiftUI
import CoreData
import PDFKit
import UIKit
import SwiftUI
import CoreData
import PDFKit
import UIKit

import SwiftUI
import CoreData
import PDFKit
import UIKit
import UniformTypeIdentifiers

// Main Document List View
struct DocumentListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.name, ascending: true)],
        animation: .default
    ) private var items: FetchedResults<Folder>
    
    @State private var documentPickerPresented = false
    @State private var isRenameSheetVisible = false
    @State private var documentToRename: Folder?
    @State private var newName: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Grid view for documents (Names and Types)
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(items, id: \.self) { item in
                            VStack {
                               
                                
                                // Show preview for different file types (PDF, DOCX, TXT)
                                FilePreviewView(item: item)
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        // Open document in preview (you can add additional behavior if needed)
                                    }
                                
                                
                                Text(item.name ?? "Unnamed Item")
                                    .font(.headline)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                
                                Text(item.fileType ?? "Photo")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    deleteItem(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    documentToRename = item
                                    newName = item.name ?? "Unnamed Item"
                                    isRenameSheetVisible = true
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                // Button to add a document
                Button(action: {
                    documentPickerPresented = true
                }) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                        Text("Add Document")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .sheet(isPresented: $documentPickerPresented) {
                    DocumentPickerView { url in
                        handleDocumentSelection(url: url)
                    }
                }
            }
            .navigationTitle("Documents")
            .sheet(isPresented: $isRenameSheetVisible) {
                RenameSheet(photo: documentToRename, newName: $newName, isVisible: $isRenameSheetVisible)
            }
        }
    }
    
    private func handleDocumentSelection(url: URL) {
        do {
            let documentData = try Data(contentsOf: url)
            let documentType = url.pathExtension.lowercased()
            let documentName = url.lastPathComponent
            
            saveDocumentData(data: documentData, name: documentName, type: documentType)
        } catch {
            print("Error reading document: \(error.localizedDescription)")
        }
    }
    
    private func saveDocumentData(data: Data, name: String, type: String) {
        let newItem = Folder(context: viewContext)
        newItem.name = name
        newItem.fileData = data
        newItem.fileType = type
        
        do {
            try viewContext.save()
            print("Document saved successfully")
        } catch {
            print("Failed to save document data: \(error.localizedDescription)")
        }
    }

    private func deleteItem(_ item: Folder) {
        withAnimation {
            viewContext.delete(item)
            do {
                try viewContext.save()
                print("Item deleted successfully")
            } catch {
                print("Error deleting item: \(error.localizedDescription)")
            }
        }
    }
}
struct FilePreviewView: View {
    var item: Folder
    
    var body: some View {
        Group {
            if let fileType = item.fileType {
                // Handle PDF preview
                if fileType == "pdf", let fileData = item.fileData {
                    if let pdfDocument = PDFDocument(data: fileData) {
                        PDFThumbnailView(pdfDocument: pdfDocument)
                            .frame(width: 100, height: 100)
                    }
                }
                // Handle TXT preview
                else if fileType == "txt", let fileData = item.fileData {
                    if let text = String(data: fileData, encoding: .utf8) {
                        Text(text)
                            .lineLimit(3)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                            .truncationMode(.tail)
                    }
                }
                // Handle DOCX preview
                else if fileType == "docx", let fileData = item.fileData {
                    Image(systemName: "doc.text")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                }
                // Ignore image files (skip displaying image previews)
                else {
//                     Optionally, you can add a default icon for unsupported files
                     Image(systemName: "doc.fill")
                         .resizable()
                         .scaledToFit()
                         .frame(width: 100, height: 100)
                         .foregroundColor(.gray)
                }
            }
            else {
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
            }
        }
    }
}

extension String {
    var isImageType: Bool {
        return ["jpg", "jpeg", "png", "gif", "bmp", "tiff"].contains(self.lowercased())
    }
}

// Large Preview View (Full-screen preview of selected document)
struct LargePreviewView: View {
    var document: Folder?
    
    var body: some View {
        VStack {
            if let document = document {
                if let fileType = document.fileType, fileType == "pdf", let fileData = document.fileData {
                    if let pdfDocument = PDFDocument(data: fileData) {
                        PDFThumbnailView(pdfDocument: pdfDocument)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                    }
                } else if let fileType = document.fileType, fileType == "txt", let fileData = document.fileData {
                    Text("Text File Preview")
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let fileType = document.fileType, fileType == "docx", let fileData = document.fileData {
                    Text("Word Document Preview")
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else {
                    Text("No preview available")
                        .padding()
                }
            }
        }
        .navigationBarItems(trailing: Button("Close") {
            // Close the preview
        })
    }
}

// Rename Sheet (Restricts changing file extensions while renaming)
struct DocRenameSheet: View {
    var photo: Folder?
    @Binding var newName: String
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack {
            TextField("Enter new name", text: $newName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
                Button("Cancel") {
                    isVisible = false
                }
                .padding()
                
                Button("Save") {
                    if let photo = photo {
                        // Save only the name, keep the file extension unchanged
                        let fileExtension = photo.name?.split(separator: ".").last ?? ""
                        photo.name = newName + "." + fileExtension
                        try? photo.managedObjectContext?.save()
                    }
                    isVisible = false
                }
                .padding()
            }
        }
        .padding()
    }
}

//extension String {
//    var isImageType: Bool {
//        return ["jpg", "jpeg", "png", "gif", "bmp", "tiff"].contains(self.lowercased())
//    }
//}


// PDF Thumbnail View (for PDF document previews)
struct PDFThumbnailView: View {
    var pdfDocument: PDFDocument
    
    var body: some View {
        PDFViewRepresentable(pdfDocument: pdfDocument)
            .frame(width: 100, height: 100)
            .clipped()
            .cornerRadius(8)
    }
}

struct PDFViewRepresentable: UIViewRepresentable {
    var pdfDocument: PDFDocument
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.document = pdfDocument
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}

// Document Picker View
struct DocumentPickerView: View {
    var onDocumentPicked: (URL) -> Void
    
    var body: some View {
        DocumentPickerController(onDocumentPicked: onDocumentPicked)
    }
}

struct DocumentPickerController: UIViewControllerRepresentable {
    var onDocumentPicked: (URL) -> Void
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(onDocumentPicked: onDocumentPicked)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item])
        documentPicker.delegate = context.coordinator
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onDocumentPicked: (URL) -> Void
        
        init(onDocumentPicked: @escaping (URL) -> Void) {
            self.onDocumentPicked = onDocumentPicked
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                onDocumentPicked(url)
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {}
    }
}

// Rename Sheet
//struct DocRenameSheet: View {
//    var photo: Folder?
//    @Binding var newName: String
//    @Binding var isVisible: Bool
//    
//    var body: some View {
//        VStack {
//            TextField("Enter new name", text: $newName)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//            
//            HStack {
//                Button("Cancel") {
//                    isVisible = false
//                }
//                .padding()
//                
//                Button("Save") {
//                    if let photo = photo {
//                        photo.docname = newName
//                        // Save changes to Core Data
//                        try? photo.managedObjectContext?.save()
//                    }
//                    isVisible = false
//                }
//                .padding()
//            }
//        }
//        .padding()
//    }
//}
