//
//  ContentView.swift
//  FileManagerPlus
//
//  Created by MANIKANDAN on 09/01/25.
//

import SwiftUI
import CoreData



class CopyPasteManager: ObservableObject {
    @Published var folderToCopy: Folder? = nil
    @Published var targetCategory: String? = nil
    @Published var isMove: Bool = false
}

//struct ContentView: View {
//    @EnvironmentObject var copyPasteManager: CopyPasteManager
//
//    var body: some View {
//        NavigationView {
//            List {
//                NavigationLink("Screen 1", destination: ScreenView(category: "Screen1").environmentObject(copyPasteManager))
//                NavigationLink("Screen 2", destination: ScreenView(category: "Screen2").environmentObject(copyPasteManager))
//                NavigationLink("Screen 3", destination: ScreenView(category: "Screen3").environmentObject(copyPasteManager))
//                NavigationLink("Screen 4", destination: ScreenView(category: "Screen4").environmentObject(copyPasteManager))
//                NavigationLink("Bin (Screen 5)", destination: ScreenView(category: "Bin", isBin: true).environmentObject(copyPasteManager))
//                NavigationLink("Favorites", destination: ScreenView(category: "Favorites").environmentObject(copyPasteManager))
//            }
//            .navigationTitle("Home")
//        }
//    }
//}
//
//struct ScreenView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//    @FetchRequest private var folders: FetchedResults<Folder>
//    @EnvironmentObject var copyPasteManager: CopyPasteManager
//
//    let category: String
//    let isBin: Bool
//
//    @State private var folderName: String = ""
//    @State private var sortOption: SortOption = .nameAscending
//    @State private var isRenaming: Bool = false
//    @State private var folderToRename: Folder?
//
//
//    @State private var showAlert: Bool = false
//    @State private var folderNameToUse: String? = nil
//    @State private var folderToReplace: Folder? = nil
//
//
//    enum SortOption: String, CaseIterable {
//        case nameAscending = "Name (A-Z)"
//        case nameDescending = "Name (Z-A)"
//        case dateAscending = "Date (Oldest First)"
//        case dateDescending = "Date (Newest First)"
//    }
//
//    init(category: String, isBin: Bool = false) {
//        self.category = category
//        self.isBin = isBin
//
//        _folders = FetchRequest(
//            entity: Folder.entity(),
//            sortDescriptors: [NSSortDescriptor(keyPath: \Folder.name, ascending: true)],
//            predicate: category == "Favorites"
//                ? NSPredicate(format: "isFavorite == true AND isdeleted == false")
//                : isBin
//                    ? NSPredicate(format: "isdeleted == true")
//                    : NSPredicate(format: "category == %@ AND isdeleted == false", category)
//        )
//    }
//
//    var body: some View {
//        VStack {
//            // Dropdown menu for sorting
//            HStack {
//                Menu {
//                    Button("Name (A-Z)") {
//                        sortOption = .nameAscending
//                        updateFetchRequest()
//                    }
//                    Button("Name (Z-A)") {
//                        sortOption = .nameDescending
//                        updateFetchRequest()
//                    }
//                    Button("Date (Oldest First)") {
//                        sortOption = .dateAscending
//                        updateFetchRequest()
//                    }
//                    Button("Date (Newest First)") {
//                        sortOption = .dateDescending
//                        updateFetchRequest()
//                    }
//                } label: {
//                    Label("Sort: \(sortOption.rawValue)", systemImage: "arrow.up.arrow.down.circle")
//                        .font(.headline)
//                        .padding()
//                        .foregroundColor(.blue)
//                        .background(Color(.secondarySystemBackground))
//                        .cornerRadius(8)
//                }
//                Spacer()
//            }
//            .padding()
//
//            // Paste Button
//            if copyPasteManager.folderToCopy != nil {
//                Button(action: pasteFolder) {
//                    Text("Paste Folder")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                        .font(.headline)
//                }
//                .padding(.bottom)
//            }
//
//            ScrollView {
//                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
//                    ForEach(folders) { folder in
//                        VStack {
//                            Image(systemName: folder.isFavorite ? "star.fill" : "folder")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 50, height: 50)
//                                .foregroundColor(folder.isFavorite ? .yellow : .blue)
//                            Text(folder.name ?? "Untitled")
//                                .font(.caption)
//
//                            if isRenaming && folderToRename == folder {
//                                TextField("Enter new name", text: $folderName, onCommit: {
//                                    renameFolder(folder)
//                                })
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                                .padding()
//                            } else {
//                                Text(folder.name ?? "Untitled")
//                                    .font(.caption)
//                                    .padding(.bottom, 5)
//                                    .onTapGesture {
//                                        startRename(folder)
//                                    }
//                            }
//                        }
//                        .padding()
//                        .contextMenu {
//                            if !isBin {
//                                Button("Copy") {
//                                    copyPasteManager.folderToCopy = folder
//                                    copyPasteManager.targetCategory = category
//                                    copyPasteManager.isMove = false
//                                }
//                                Button("Move") {
//                                    copyPasteManager.folderToCopy = folder
//                                    copyPasteManager.targetCategory = category
//                                    copyPasteManager.isMove = true
//                                }
//                            }
//                            if isBin {
//                                Button("Restore") {
//                                    restoreFolder(folder)
//                                }
//                                Button("Delete Permanently", role: .destructive) {
//                                    deleteFolderPermanently(folder)
//                                }
//                            } else {
//                                Button("Move to Bin") {
//                                    moveToBin(folder)
//                                }
//                            }
//
//                            if category != "Favorites" {
//                                if folder.isFavorite {
//                                    Button("Remove from Favorites") {
//                                        toggleFavoriteStatus(folder)
//                                    }
//                                } else {
//                                    Button("Add to Favorites") {
//                                        toggleFavoriteStatus(folder)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//                .padding()
//            }
//
//            if !isBin {
//                HStack {
//                    TextField("Enter folder name", text: $folderName)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    Button(action: addFolder) {
//                        Text("Add")
//                    }
//                    .buttonStyle(.borderedProminent)
//                }
//                .padding()
//            }
//
//            if isBin {
//                Button("Empty Bin", action: emptyBin)
//                    .buttonStyle(.borderedProminent)
//                    .padding()
//            }
//
//            Spacer()
//        }
//        .onAppear {
//            updateFetchRequest()
//        }
//        .navigationTitle(isBin ? "Bin" : category)
//
//        .toolbar {
//            if !isBin {
//                EditButton()
//            }
//        }
//        .alert(isPresented: $showAlert) {
//            Alert(
//                title: Text("Folder Already Exists"),
//                message: Text("A folder named '\(folderNameToUse ?? "")' already exists in this category. Do you want to replace it or rename it?"),
//                primaryButton: .destructive(Text("Replace")) {
//                    // Replace the folder with the new one
//                    if let folderToReplace = folderToReplace {
//                        viewContext.delete(folderToReplace)
//                        try? viewContext.save()
//                        createNewFolder(named: folderNameToUse ?? "Untitled")
//                    }
//                },
//                secondaryButton: .default(Text("Rename")) {
//                    // Rename the folder by adding a "copy" suffix
//                    if let folderName = folderNameToUse {
//                        var newFolderName = folderName + " copy"
//                        var counter = 1
//                        while folderExists(named: newFolderName) {
//                            newFolderName = folderName + " copy \(counter)"
//                            counter += 1
//                        }
//                        createNewFolder(named: newFolderName)
//                    }
//                }
//            )
//        }
//    }
//
//
//    private func updateFetchRequest() {
//        let sortDescriptor: SortDescriptor<Folder>
//        switch sortOption {
//        case .nameAscending:
//            sortDescriptor = SortDescriptor(\Folder.name, order: .forward)
//        case .nameDescending:
//            sortDescriptor = SortDescriptor(\Folder.name, order: .reverse)
//        case .dateAscending:
//            sortDescriptor = SortDescriptor(\Folder.createdDate, order: .forward)
//        case .dateDescending:
//            sortDescriptor = SortDescriptor(\Folder.createdDate, order: .reverse)
//        }
//
//        folders.sortDescriptors = [sortDescriptor]
//    }
//    private func addFolder() {
//        var newFolderName = "Newfolder"
//        var counter = 1
//
//        // Check if the folder with this name already exists in the current category
//        while folderExists(named: newFolderName) {
//            // If it exists, increment the counter and try a new name
//            newFolderName = "Newfolder\(counter)"
//            counter += 1
//        }
//
//        // Create the new folder with the unique name
//        let newFolder = Folder(context: viewContext)
//        newFolder.name = newFolderName
//        newFolder.category = category
//        newFolder.createdDate = Date() // Set creation date with time
//
//        newFolder.isdeleted = false
//
//
//
//        do {
//            try viewContext.save()
//            print("Folder added: \(newFolderName)")
//        } catch {
//            print("Error saving folder: \(error.localizedDescription)")
//        }
//    }
//
//    private func folderExists(named name: String) -> Bool {
//        // Fetch folders with the same name and category from CoreData
//        let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "name == %@ AND category == %@ AND isdeleted == false", name, category)
//
//        do {
//            let existingFolders = try viewContext.fetch(fetchRequest)
//            return !existingFolders.isEmpty // If the array is empty, the folder does not exist
//        } catch {
//            print("Error checking if folder exists: \(error.localizedDescription)")
//            return false
//        }
//    }
//
//    // Renaming Folder Logic
//       private func startRename(_ folder: Folder) {
//           isRenaming = true
//           folderToRename = folder
//           folderName = folder.name ?? ""
//       }
//
//    private func renameFolder(_ folder: Folder) {
//        var newName = folderName.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        // If the new name is empty, return early
//        if newName.isEmpty {
//            print("Error: Folder name cannot be empty.")
//            return
//        }
//
//        // Check if the new folder name already exists
//        if folderExists(named: newName) {
//            // If the folder exists, append " copy" to the name
//            var copyIndex = 1
//            var newNameWithSuffix = newName + " copy"
//
//            // Ensure the name is unique by checking if a folder with this name exists
//            while folderExists(named: newNameWithSuffix) {
//                copyIndex += 1
//                newNameWithSuffix = newName + " copy \(copyIndex)"
//            }
//
//            // Use the unique name
//            newName = newNameWithSuffix
//        }
//
//        // Rename the folder with the new name
//        folder.name = newName
//        isRenaming = false
//        folderToRename = nil
//
//        // Save the changes to Core Data
//        do {
//            try viewContext.save()
//        } catch {
//            print("Error renaming folder: \(error.localizedDescription)")
//        }
//
//    }
//
//
//
//
//    private func moveToBin(_ folder: Folder) {
//        folder.isdeleted = true
//        folder.category = "Bin"
//        do {
//            try viewContext.save()
//        } catch {
//            print("Error moving folder to bin: \(error)")
//        }
//    }
//
//    private func restoreFolder(_ folder: Folder) {
//        folder.isdeleted = false
//        folder.category = category
//        do {
//            try viewContext.save()
//        } catch {
//            print("Error restoring folder: \(error)")
//        }
//    }
//
//    private func deleteFolderPermanently(_ folder: Folder) {
//        viewContext.delete(folder)
//        do {
//            try viewContext.save()
//        } catch {
//            print("Error deleting folder permanently: \(error)")
//        }
//    }
//
//    private func emptyBin() {
//        let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "category == 'Bin' AND isdeleted == true")
//        do {
//            let foldersInBin = try viewContext.fetch(fetchRequest)
//            for folder in foldersInBin {
//                viewContext.delete(folder)
//            }
//            try viewContext.save()
//        } catch {
//            print("Error emptying bin: \(error)")
//        }
//    }
//
//    private func toggleFavoriteStatus(_ folder: Folder) {
//        folder.isFavorite.toggle()
//        do {
//            try viewContext.save()
//        } catch {
//            print("Error toggling favorite status: \(error)")
//        }
//    }
//    private func pasteFolder() {
//        guard let folderToCopy = copyPasteManager.folderToCopy else { return }
//
//        var newFolderName = folderToCopy.name ?? "Untitled"
//
//        // Check if the folder with this name already exists
//        if folderExists(named: newFolderName) {
//            // If the folder exists, show the alert
//            showAlert = true
//            folderToReplace = fetchFolder(named: newFolderName)
//            folderNameToUse = newFolderName // Default to original name
//            return
//        }
//
//        // Proceed to create the folder if no name conflict
//        createNewFolder(named: newFolderName)
//    }
//
//    private func createNewFolder(named folderName: String) {
//        let newFolder = Folder(context: viewContext)
//        newFolder.name = folderName
//        newFolder.category = category
//        newFolder.isdeleted = false
//        newFolder.isFavorite = copyPasteManager.folderToCopy?.isFavorite ?? false
//
//        do {
//            try viewContext.save()
//            if copyPasteManager.isMove {
//                // If move, delete the original folder
//                viewContext.delete(copyPasteManager.folderToCopy!)
//                try viewContext.save()
//            }
//            copyPasteManager.folderToCopy = nil
//            copyPasteManager.isMove = false
//        } catch {
//            print("Error pasting folder: \(error.localizedDescription)")
//        }
//    }
//
//    private func fetchFolder(named name: String) -> Folder? {
//        // Fetch the folder with the specified name
//        let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "name == %@ AND category == %@", name, category)
//
//        do {
//            let folders = try viewContext.fetch(fetchRequest)
//            return folders.first
//        } catch {
//            print("Error fetching folder: \(error.localizedDescription)")
//            return nil
//        }
//    }
//
//
//    // Ensure unique folder name in the target category by appending numeric suffix
//    private func ensureUniqueFolderName(_ folderName: String) -> String {
//        var newName = folderName
//        var suffix = 1
//
//        // Fetch existing folders in the target category to check for duplicate names
//        let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "category == %@ AND name == %@", category, newName)
//
//        // Keep checking for duplicates and increment the suffix if needed
//        while let _ = try? viewContext.fetch(fetchRequest).first {
//            newName = "\(folderName)\(suffix)"  // Append numeric suffix to the folder name
//            suffix += 1
//            fetchRequest.predicate = NSPredicate(format: "category == %@ AND name == %@", category, newName) // Update predicate
//        }
//
//        return newName
//    }
//
//
//}
//
//#Preview {
//    ContentView()
//}
