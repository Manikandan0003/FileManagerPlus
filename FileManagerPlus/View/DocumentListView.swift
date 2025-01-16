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
import UniformTypeIdentifiers

struct DocumentListView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.name, ascending: true)],
        animation: .default
    ) private var items: FetchedResults<Folder>
    
    @State private var documentPickerPresented = false
    @State private var isRenameSheetVisible = false
    @State private var documentToRename: Folder?
    @State private var newName: String = ""
    @State private var sortOption: SortOption = .nameAscending

    
    enum SortOption: String, CaseIterable {
        case nameAscending = "Name (A-Z)"
        case nameDescending = "Name (Z-A)"
        case dateAscending = "Date (Oldest First)"
        case dateDescending = "Date (Newest First)"
    }
    
    var body: some View {
        ZStack {
        VStack {
            HStack {
                Menu {
                    Button("Name (A-Z)") {
                        sortOption = .nameAscending
                        updateFetchRequest()
                    }
                    Button("Name (Z-A)") {
                        sortOption = .nameDescending
                        updateFetchRequest()
                    }
                    Button("Date (Oldest First)") {
                        sortOption = .dateAscending
                        updateFetchRequest()
                    }
                    Button("Date (Newest First)") {
                        sortOption = .dateDescending
                        updateFetchRequest()
                    }
                } label: {
                    let gradient = LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    Label("Sort: \(sortOption.rawValue)", systemImage: "arrow.up.arrow.down.circle")
                        .font(.headline)
                        .padding()
                        .foregroundStyle(gradient)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(gradient.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                        )
                        .cornerRadius(10)
                }
                Spacer()
            }
            .padding()
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(items, id: \.self) { item in
                        VStack {
                            
                            
                            FilePreviewView(item: item)
                                .frame(width: 100, height: 100)
                                .cornerRadius(8)
                                .onTapGesture {
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
            
            Button(action: {
                documentPickerPresented = true
            }) {
                HStack {
                    Image(systemName: "doc.text.fill")
                    Text("Add Document")
                }
                .padding()
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .opacity(0.1)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                )                    .cornerRadius(8)
            }
            .sheet(isPresented: $documentPickerPresented) {
                DocumentPickerView { url in
                    handleDocumentSelection(url: url)
                }
            }
        }
            if isRenameSheetVisible {
                RenameSheet(photo: documentToRename, newName: $newName, isVisible: $isRenameSheetVisible)
            }
    }
       
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .padding(8)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .opacity(0.1)
                            )
                   )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                    )
                }
            }
        }
        .navigationTitle("Documents")

    }
    
    private func updateFetchRequest() {
        let sortDescriptor: SortDescriptor<Folder>
        switch sortOption {
        case .nameAscending:
            sortDescriptor = SortDescriptor(\Folder.name, order: .forward)
        case .nameDescending:
            sortDescriptor = SortDescriptor(\Folder.name, order: .reverse)
        case .dateAscending:
            sortDescriptor = SortDescriptor(\Folder.createdDate, order: .forward)
        case .dateDescending:
            sortDescriptor = SortDescriptor(\Folder.createdDate, order: .reverse)
        }

        items.sortDescriptors = [sortDescriptor]
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
                if fileType == "pdf", let fileData = item.fileData {
                    if let pdfDocument = PDFDocument(data: fileData) {
                        PDFThumbnailView(pdfDocument: pdfDocument)
                            .frame(width: 100, height: 100)
                    }
                }
                else if fileType == "txt", let fileData = item.fileData {
                    if let text = String(data: fileData, encoding: .utf8) {
                        Text(text)
                            .lineLimit(3)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                            .truncationMode(.tail)
                    }
                }
                else if fileType == "docx", let fileData = item.fileData {
                    Image(systemName: "doc.text")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                }
                else {
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
        })
    }
}

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

