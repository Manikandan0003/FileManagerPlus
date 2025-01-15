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
        NavigationView {
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
                            Label("Sort: \(sortOption.rawValue)", systemImage: "arrow.up.arrow.down.circle")
                                .font(.headline)
                                .padding()
                                .foregroundColor(.blue)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                        }
                        Spacer()
                    }
                    .padding()
                    // Grid of photos
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(photos, id: \.self) { photo in
                                if let imageData = photo.imageData, let uiImage = UIImage(data: imageData) {
                                    VStack {
                                        // Image
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
                                        
                                        // Photo name
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
                                        
                                        // Add Rename Option to Context Menu
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
                    
                    // Embedded PhotosPicker
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Add Photo")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
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
                
                // Full-screen photo preview
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
                
                // Rename Sheet
                if isRenameSheetVisible {
                    RenameSheet(photo: photoToRename, newName: $newName, isVisible: $isRenameSheetVisible)
                }
            }
            .navigationTitle("Saved Photos")
        }
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
        // Generate image name
        let imageName = generateImageName()
        
        let newPhoto = Folder(context: viewContext)
        newPhoto.name = imageName
        newPhoto.imageData = data
        newPhoto.createdDate = Date() // Set creation date with time

        
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
