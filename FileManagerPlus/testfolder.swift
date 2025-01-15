//
//  testfolder.swift
//  FileManagerPlus
//
//  Created by MANIKANDAN on 14/01/25.
//

import SwiftUI
import CoreData

struct FolderView1: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var folders: FetchedResults<Folder>
    @EnvironmentObject var copyPasteManager: CopyPasteManager

    let category: String
    let isBin: Bool

    @State private var showAlert = false
       @State private var alertMessage = ""
       @State private var folderName: String = ""
       @State private var sortOption: SortOption = .nameAscending
       @State private var isRenaming: Bool = false
       @State private var folderNameToUse: String? = nil
       @State private var folderToReplace: Folder? = nil
       @State private var selectedColor: Color = .blue  // For color picker
       @State private var isAddingFolder: Bool = false  // State to trigger folder addition
       
    
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
        VStack {
            // Button to Add a Folder
                       Button(action: {
                           isAddingFolder = true
                           folderName = ""
                       }) {
                           Text("Add Folder")
                               .padding()
                               .background(Color.green)
                               .foregroundColor(.white)
                               .cornerRadius(8)
                               .font(.headline)
                       }
                       .padding(.top)

                       // Folder Name Input when Adding a Folder
                       if isAddingFolder {
                           VStack {
                               TextField("Enter new folder name", text: $folderName)
                                   .textFieldStyle(RoundedBorderTextFieldStyle())
                                   .padding()

                               Button("Save Folder") {
                                   saveNewFolder(name: folderName)
                               }
                               .padding()
                               .disabled(folderName.isEmpty)  // Disable button if the folder name is empty
                           }
                           .padding()
                       }
            
            // Dropdown menu for sorting
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

            // Paste Button
            if copyPasteManager.folderToCopy != nil {
                Button(action: pasteFolder) {
                    Text("Paste Folder")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .font(.headline)
                }
                .padding(.bottom)
            }

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(folders) { folder in
                        VStack {
                            Image(systemName: folder.isFavorite ? "star.fill" : "folder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .foregroundColor(folder.isFavorite ? .yellow : folderColor(folder)) // Apply color here
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
                                    isRenaming = true
                                    folderName = folder.name ?? ""
                                    folderToReplace = folder
                                }
                                Button("Change Color") {
                                    selectedColor = colorFromString(folder.color ?? "blue")
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
                .padding()
            }

            // Renaming Folder Section
            if isRenaming, let folderToRename = folderToReplace {
                VStack {
                    TextField("Enter new folder name", text: $folderName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button("Rename Folder") {
                        folderToRename.name = folderName
                        do {
                            try viewContext.save()
                            isRenaming = false
                        } catch {
                            print("Error renaming folder: \(error)")
                        }
                    }
                    .padding()
                }
            }

            // Folder Color Change
            ColorPicker("Choose Folder Color", selection: $selectedColor)
                .onChange(of: selectedColor) { newColor in
                    if let folderToChangeColor = folderToReplace {
                        changeFolderColor(folderToChangeColor, color: newColor)
                    }
                }
                .padding()

            Spacer()
        }
        .onAppear {
            updateFetchRequest()
        }
        .navigationTitle(isBin ? "Bin" : category)
        .toolbar {
            if !isBin {
                EditButton()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Folder Already Exists"),
                message: Text("A folder named '\(folderNameToUse ?? "")' already exists in this category. Do you want to replace it or rename it?"),
                primaryButton: .destructive(Text("Replace")) {
                    // Replace the folder with the new one
                    if let folderToReplace = folderToReplace {
                        viewContext.delete(folderToReplace)
                        try? viewContext.save()
                        createNewFolder(named: folderNameToUse ?? "Untitled")
                    }
                },
                secondaryButton: .default(Text("Rename")) {
                    // Rename the folder by adding a "copy" suffix
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
    }
    
    // Helper functions to handle renaming, color change, etc.
       private func saveNewFolder(name: String) {
           let newFolder = Folder(context: viewContext)
           newFolder.name = name
           newFolder.category = category
           newFolder.isFavorite = false
           newFolder.color = "blue"  // Default color
           newFolder.createdDate = Date()

           do {
               try viewContext.save()
               isAddingFolder = false  // Hide the input field after saving
           } catch {
               print("Error saving new folder: \(error)")
           }
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
                // If move, delete the original folder
                viewContext.delete(copyPasteManager.folderToCopy!)
                try viewContext.save()
            }
            copyPasteManager.folderToCopy = nil
            copyPasteManager.isMove = false
        } catch {
            print("Error pasting folder: \(error.localizedDescription)")
        }
    }
    
    private func pasteFolder() {
        guard let folderToCopy = copyPasteManager.folderToCopy else { return }

        var newFolderName = folderToCopy.name ?? "Untitled"

        // Check if the folder with this name already exists
        if folderExists(named: newFolderName) {
            // If the folder exists, show the alert
            showAlert = true
            folderToReplace = fetchFolder(named: newFolderName)
            folderNameToUse = newFolderName // Default to original name
            return
        }

        // Proceed to create the folder if no name conflict
        createNewFolder(named: newFolderName)
    }
    
    
    private func fetchFolder(named name: String) -> Folder? {
        // Fetch the folder with the specified name
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
    
    
    private func folderExists(named name: String) -> Bool {
        // Fetch folders with the same name and category from CoreData
        let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@ AND category == %@ AND isdeleted == false", name, category)

        do {
            let existingFolders = try viewContext.fetch(fetchRequest)
            return !existingFolders.isEmpty // If the array is empty, the folder does not exist
        } catch {
            print("Error checking if folder exists: \(error.localizedDescription)")
            return false
        }
    }
    // Helper functions to handle renaming, color change, etc.
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

    private func folderColor(_ folder: Folder) -> Color {
        return colorFromString(folder.color ?? "blue")
    }

    private func colorFromString(_ color: String) -> Color {
        switch color {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        default: return .blue
        }
    }

    private func changeFolderColor(_ folder: Folder, color: Color) {
        let colorString = colorToString(color)
        folder.color = colorString
        do {
            try viewContext.save()
        } catch {
            print("Error changing folder color: \(error)")
        }
    }

    private func colorToString(_ color: Color) -> String {
        if color == .red { return "red" }
        if color == .green { return "green" }
        if color == .blue { return "blue" }
        return "blue"
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

    private func toggleFavoriteStatus(_ folder: Folder) {
        folder.isFavorite.toggle()
        do {
            try viewContext.save()
        } catch {
            print("Error toggling favorite status: \(error)")
        }
    }
}
