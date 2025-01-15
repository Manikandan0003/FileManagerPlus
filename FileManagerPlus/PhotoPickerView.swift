//
//  PhotoPickerView.swift
//  FileManagerPlus
//
//  Created by MANIKANDAN on 15/01/25.
//


import SwiftUI
import PhotosUI
import CoreData

struct PhotoPickerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem? = nil
    let category: String

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
            Text("Select a photo")
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
                        dismiss() // Dismiss after saving
                    }
                }
            }
        }
    }

    private func savePhotoData(data: Data) {
        let newPhoto = Folder(context: viewContext)
        newPhoto.name = "New Photo" // Optional: Assign a default name
        newPhoto.imageData = data
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to save photo data: \(error)")
        }
    }
}


