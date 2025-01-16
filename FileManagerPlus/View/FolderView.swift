//
//  FolderView.swift
//  FileManagerPlus
//
//  Created by MANIKANDAN on 13/01/25.
//

import SwiftUI
import CoreData
import PhotosUI

struct FolderView: View {
    @Environment(\.presentationMode) var presentationMode
        @Environment(\.managedObjectContext) private var viewContext
        @FetchRequest private var folders: FetchedResults<Folder>
        @EnvironmentObject var copyPasteManager: CopyPasteManager

        let category: String
        let isBin: Bool
    let gradient = LinearGradient(
        colors: [.blue, .purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var folderToAddPhoto: Folder? = nil
    @State private var isRenameSheetVisible = false
    @State private var photoToRename: Folder?
    @State private var newName: String = ""



    
        @State private var showAlert = false
        @State private var alertMessage = ""
        @State private var folderName: String = ""
        @State private var sortOption: SortOption = .nameAscending
        @State private var isRenaming: Bool = false
        @State private var folderNameToUse: String? = nil
        @State private var folderToReplace: Folder? = nil
        @State private var selectedColor: String = "blue"
        @State private var showColorSelection = false
        @State private var folderToChangeColor: Folder? = nil

        enum SortOption: String, CaseIterable {
            case nameAscending = "Name (A-Z)"
            case nameDescending = "Name (Z-A)"
            case dateAscending = "Date (Oldest First)"
            case dateDescending = "Date (Newest First)"
        }

        init(category: String, isBin: Bool = false) {
            self.category = category
            self.isBin = isBin

            _folders = FetchRequest(
                entity: Folder.entity(),
                sortDescriptors: [NSSortDescriptor(keyPath: \Folder.name, ascending: true)],
                predicate: category == "Favorites"
                    ? NSPredicate(format: "isFavorite == true AND isdeleted == false")
                    : isBin
                        ? NSPredicate(format: "isdeleted == true")
                        : NSPredicate(format: "category == %@ AND isdeleted == false", category)
            )
        }

    var body: some View {
        ZStack{
        VStack {
            HStack{
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
            if copyPasteManager.folderToCopy != nil {
                Button(action: pasteFolder) {
                    Text("Paste Folder")
                        .padding()
                        .foregroundStyle(gradient)
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
                                .stroke(Color(UIColor.systemGray4), lineWidth: 1) // Border for emphasis
                        )
                        .cornerRadius(8)
                        .font(.headline)
                }
                .padding(.bottom)
            }
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(folders) { folder in
                        NavigationLink(destination: FolderView(category: folder.name ?? "No Name", isBin: isBin)) {
                            
                            VStack {
                                Image(systemName: folder.isFavorite ? "star.fill" : "folder.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .foregroundStyle(
                                        folder.isFavorite
                                        ? AnyShapeStyle(Color.yellow)
                                        : styleFromString(folder.color ?? "gradient")
                                    )
                                
                                    .padding()
                                
                                Text(folder.name ?? "Untitled")
                                    .font(.caption)
                            }
                            .padding()
                            .contextMenu {
                                if !isBin {
                                    Button("Copy") {
                                        copyPasteManager.folderToCopy = folder
                                        copyPasteManager.targetCategory = category
                                        copyPasteManager.isMove = false
                                    }
                                    Button("Move") {
                                        copyPasteManager.folderToCopy = folder
                                        copyPasteManager.targetCategory = category
                                        copyPasteManager.isMove = true
                                    }
                                    Button("Rename") {
                                        photoToRename = folder
                                        newName = folder.name ?? "Unnamed Photo"
                                        isRenameSheetVisible = true
                                        
                                    }
                                    Button("Change Color") {
                                        folderToChangeColor = folder
                                        showColorSelection.toggle()
                                    }
                                }
                                
                                if isBin {
                                    Button("Restore") {
                                        restoreFolder(folder)
                                    }
                                    Button("Delete Permanently", role: .destructive) {
                                        deleteFolderPermanently(folder)
                                    }
                                } else {
                                    Button("Move to Bin") {
                                        moveToBin(folder)
                                    }
                                }
                                
                                if category != "Favorites" {
                                    if folder.isFavorite {
                                        Button("Remove from Favorites") {
                                            toggleFavoriteStatus(folder)
                                        }
                                    } else {
                                        Button("Add to Favorites") {
                                            toggleFavoriteStatus(folder)
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                }
                .padding()
            }
            if !isBin {
                Button(action: {
                    addFolder()
                }) {
                    HStack {
                        Image(systemName: "folder.fill")
                        Text("Add Folder")
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
            }
            
        }
//            if !isBin {
//                // Button to add a document
//                Button(action: {
//                    addFolder()
//                }) {
//                    HStack {
//                        Image(systemName: "folder.fill")
//                        Text("Add Document")
//                    }
//                    .padding()
//                    .foregroundStyle(
//                        LinearGradient(
//                            colors: [.blue, .purple],
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        )
//                    )
//                    .background(
//                        RoundedRectangle(cornerRadius: 10)
//                            .foregroundStyle(
//                                LinearGradient(
//                                    colors: [.blue, .purple],
//                                    startPoint: .topLeading,
//                                    endPoint: .bottomTrailing
//                                )
//                                .opacity(0.1) // Adjust the opacity value (0.0 to 1.0)
//                            )
//                    )
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color(UIColor.systemGray4), lineWidth: 1) // Border for emphasis
//                    )                    .cornerRadius(8)
//                }
//            }
            
            if isBin {
                Button("Empty Bin", action: emptyBin)
                    .buttonStyle(.borderedProminent)
                    .padding()
            }
            if isRenameSheetVisible {
                RenameSheet(photo: photoToRename, newName: $newName, isVisible: $isRenameSheetVisible)
            }
            
            Spacer()
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
        
        
        .onAppear {
            updateFetchRequest()
        }
        .navigationTitle(isBin ? "Bin" : category)
        //            .toolbar {
        //                if !isBin {
        //                    EditButton()
        //                }
        //            }
        //
        
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Folder Already Exists"),
                message: Text("A folder named '\(folderNameToUse ?? "")' already exists in this category. Do you want to replace it or rename it?"),
                primaryButton: .destructive(Text("Replace")) {
                    if let folderToReplace = folderToReplace {
                        viewContext.delete(folderToReplace)
                        try? viewContext.save()
                        createNewFolder(named: folderNameToUse ?? "Untitled")
                    }
                },
                secondaryButton: .default(Text("Rename")) {
                    if let folderName = folderNameToUse {
                        var newFolderName = folderName + " copy"
                        var counter = 1
                        while folderExists(named: newFolderName) {
                            newFolderName = folderName + " copy \(counter)"
                            counter += 1
                        }
                        createNewFolder(named: newFolderName)
                    }
                }
            )
        }
        
        .sheet(isPresented: $showColorSelection) {
            ColorSelectionView(selectedColor: $selectedColor, onColorSelected: { color in
                if let folder = folderToChangeColor {
                    updateFolderColor(folder, color: color)
                }
                showColorSelection = false
            })
        }
    }
                
    private func styleFromString(_ colorString: String) -> AnyShapeStyle {
        switch colorString {
        case "red":
            return AnyShapeStyle(Color.red)
        case "green":
            return AnyShapeStyle(Color.green)
        case "blue":
            return AnyShapeStyle(Color.blue)
        case "yellow":
            return AnyShapeStyle(Color.yellow)
        case "black":
            return AnyShapeStyle(Color.black)
        case "gradient":
            return AnyShapeStyle(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        default:
            return AnyShapeStyle(Color.blue)
        }
    }

       
        private func updateFolderColor(_ folder: Folder, color: String) {
          folder.color = color
          do {
              try viewContext.save()
              print("Folder color updated to: \(color)")
          } catch {
              print("Error updating folder color: \(error)")
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

            folders.sortDescriptors = [sortDescriptor]
        }
        private func addFolder() {
            var newFolderName = "Newfolder"
            var counter = 1

            while folderExists(named: newFolderName) {
                newFolderName = "Newfolder\(counter)"
                counter += 1
            }

            let newFolder = Folder(context: viewContext)
            newFolder.name = newFolderName
            newFolder.category = category
            newFolder.createdDate = Date()
            newFolder.isdeleted = false
            do {
                try viewContext.save()
                print("Folder added: \(newFolderName)")
            } catch {
                print("Error saving folder: \(error.localizedDescription)")
            }
        }

        private func folderExists(named name: String) -> Bool {
            let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@ AND category == %@ AND isdeleted == false", name, category)

            do {
                let existingFolders = try viewContext.fetch(fetchRequest)
                return !existingFolders.isEmpty
            } catch {
                print("Error checking if folder exists: \(error.localizedDescription)")
                return false
            }
        }

        private func moveToBin(_ folder: Folder) {
            folder.isdeleted = true
            folder.category = "Bin"
            do {
                try viewContext.save()
            } catch {
                print("Error moving folder to bin: \(error)")
            }
        }

        private func restoreFolder(_ folder: Folder) {
            folder.isdeleted = false
            folder.category = category
            do {
                try viewContext.save()
            } catch {
                print("Error restoring folder: \(error)")
            }
        }

        private func deleteFolderPermanently(_ folder: Folder) {
            viewContext.delete(folder)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting folder permanently: \(error)")
            }
        }

        private func emptyBin() {
            let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "category == 'Bin' AND isdeleted == true")
            do {
                let foldersInBin = try viewContext.fetch(fetchRequest)
                for folder in foldersInBin {
                    viewContext.delete(folder)
                }
                try viewContext.save()
            } catch {
                print("Error emptying bin: \(error)")
            }
        }

        private func toggleFavoriteStatus(_ folder: Folder) {
            folder.isFavorite.toggle()
            do {
                try viewContext.save()
            } catch {
                print("Error toggling favorite status: \(error)")
            }
        }
        private func pasteFolder() {
            guard let folderToCopy = copyPasteManager.folderToCopy else { return }

            var newFolderName = folderToCopy.name ?? "Untitled"

            if folderExists(named: newFolderName) {
                showAlert = true
                folderToReplace = fetchFolder(named: newFolderName)
                folderNameToUse = newFolderName // Default to original name
                return
            }

            createNewFolder(named: newFolderName)
        }

        private func createNewFolder(named folderName: String) {
            let newFolder = Folder(context: viewContext)
            newFolder.name = folderName
            newFolder.category = category
            newFolder.isdeleted = false
            newFolder.isFavorite = copyPasteManager.folderToCopy?.isFavorite ?? false

            do {
                try viewContext.save()
                if copyPasteManager.isMove {
                    viewContext.delete(copyPasteManager.folderToCopy!)
                    try viewContext.save()
                }
                copyPasteManager.folderToCopy = nil
                copyPasteManager.isMove = false
            } catch {
                print("Error pasting folder: \(error.localizedDescription)")
            }
        }

        private func fetchFolder(named name: String) -> Folder? {
            let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@ AND category == %@", name, category)

            do {
                let folders = try viewContext.fetch(fetchRequest)
                return folders.first
            } catch {
                print("Error fetching folder: \(error.localizedDescription)")
                return nil
            }
        }


        private func ensureUniqueFolderName(_ folderName: String) -> String {
            var newName = folderName
            var suffix = 1

            let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "category == %@ AND name == %@", category, newName)

            while let _ = try? viewContext.fetch(fetchRequest).first {
                newName = "\(folderName)\(suffix)"
                suffix += 1
                fetchRequest.predicate = NSPredicate(format: "category == %@ AND name == %@", category, newName) 
            }

            return newName
        }


    }





