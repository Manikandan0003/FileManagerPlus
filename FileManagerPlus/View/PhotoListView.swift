//
//  PhotoListView.swift
//  FileManagerPlus
//
//  Created by MANIKANDAN on 15/01/25.
//


import SwiftUI
import PhotosUI
import CoreData

struct PhotoListView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.name, ascending: true)],
        animation: .default
    ) private var photos: FetchedResults<Folder>
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedPhoto: UIImage? = nil
    @State private var isPreviewVisible = false
    @State private var isRenameSheetVisible = false
    @State private var photoToRename: Folder?
    @State private var newName: String = ""
    @State private var sortOption: SortOption = .nameAscending
    
    enum SortOption: String, CaseIterable {
        case nameAscending = "Name (A-Z)"
        case nameDescending = "Name (Z-A)"
        case dateAscending = "Date (Oldest First)"
        case dateDescending = "Date (Newest First)"
    }


    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
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
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(photos, id: \.self) { photo in
                                if let imageData = photo.imageData, let uiImage = UIImage(data: imageData) {
                                    VStack {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipped()
                                            .cornerRadius(8)
                                            .onTapGesture {
                                                withAnimation(.easeInOut) {
                                                    selectedPhoto = uiImage
                                                    isPreviewVisible = true
                                                }
                                            }
                                        
                                        Text(photo.name ?? "Unnamed Photo")
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            deletePhoto(photo)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        
                                        Button {
                                            photoToRename = photo
                                            newName = photo.name ?? "Unnamed Photo"
                                            isRenameSheetVisible = true
                                        } label: {
                                            Label("Rename", systemImage: "pencil")
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Add Photo")
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
                        )                           .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let selectedItem {
                                if let data = try? await selectedItem.loadTransferable(type: Data.self) {
                                    savePhotoData(data: data)
                                }
                            }
                        }
                    }
                }
                
                if isPreviewVisible, let selectedPhoto {
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    Image(uiImage: selectedPhoto)
                        .resizable()
                        .scaledToFit()
                        .transition(.scale(scale: 0.9))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.8))
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                isPreviewVisible = false
                            }
                        }
                }
                
                if isRenameSheetVisible {
                    RenameSheet(photo: photoToRename, newName: $newName, isVisible: $isRenameSheetVisible)
                }
                
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
        .navigationTitle("Photos")
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

        photos.sortDescriptors = [sortDescriptor]
    }

    private func savePhotoData(data: Data) {
        let imageName = generateImageName()
        
        let newPhoto = Folder(context: viewContext)
        newPhoto.name = imageName
        newPhoto.imageData = data
        newPhoto.createdDate = Date()
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to save photo data: \(error)")
        }
    }

    private func generateImageName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let dateString = dateFormatter.string(from: Date())
        return "IMG_" + dateString
    }

    private func deletePhoto(_ photo: Folder) {
        withAnimation {
            viewContext.delete(photo)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting photo: \(error)")
            }
        }
    }
}
