//
//  CategoryView.swift
//  FileManagerPlus
//
//  Created by MANIKANDAN on 11/01/25.
//

import SwiftUI

struct CategoryView: View {
        @Environment(\.managedObjectContext) private var viewContext
        @FetchRequest private var folders: FetchedResults<Folder>
        @EnvironmentObject var copyPasteManager: CopyPasteManager
        
        let category: String
        let isBin: Bool

        @State private var folderName: String = ""
        @State private var isRenaming: Bool = false
        @State private var folderToRename: Folder?

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

        private let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        var body: some View {
            VStack {
                Text(isBin ? "Bin" : "Folders (\(category))")
                    .font(.largeTitle)
                    .padding()

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(folders) { folder in
                            VStack {
                                Image(systemName: "folder")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.blue)
                                
                                if isRenaming && folderToRename == folder {
                                    TextField("Enter new name", text: $folderName, onCommit: {
                                        renameFolder(folder)
                                    })
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                } else {
                                    Text(folder.name ?? "Untitled")
                                        .font(.caption)
                                        .padding(.bottom, 5)
                                        .onTapGesture {
                                            startRename(folder)
                                        }
                                }
                            }
                            .padding()
                            .contextMenu {
                                if !isBin {
                                    Button("Copy") {
                                        copyPasteManager.folderToCopy = folder
                                        copyPasteManager.targetCategory = category
                                        copyPasteManager.isMove = false
                                        print("Folder copied: \(folder.name ?? "Unknown"), Target Category: \(category)")
                                    }
                                    Button("Move") {
                                        copyPasteManager.folderToCopy = folder
                                        copyPasteManager.targetCategory = category
                                        copyPasteManager.isMove = true
                                        print("Folder moved: \(folder.name ?? "Unknown"), Target Category: \(category)")
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

                if !isBin {
                    HStack {
                        TextField("Enter folder name", text: $folderName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button(action: addFolder) {
                            Text("Add")
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Paste") {
                            pasteFolder()
                        }
                        .disabled(copyPasteManager.folderToCopy == nil || copyPasteManager.targetCategory != category)
                    }
                    .padding()
                }

                if isBin {
                    Button("Empty Bin", action: emptyBin)
                        .buttonStyle(.borderedProminent)
                        .padding()
                }

                Spacer()
            }
            .onAppear {
                print("Screen \(category) appeared")
                copyPasteManager.targetCategory = category
                print("Target Category set to: \(copyPasteManager.targetCategory ?? "None")")
            }
            .navigationTitle(isBin ? "Bin" : category)
            .toolbar {
                if !isBin {
                    EditButton()
                }
            }
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
            newFolder.isdeleted = false

            do {
                try viewContext.save()
            } catch {
                print("Error saving folder: \(error.localizedDescription)")
            }
        }

        private func folderExists(named name: String) -> Bool {
            let fetchRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@ AND category == %@ AND isdeleted == false", name, category)
            
            do {
                let existingFolders = try viewContext.fetch(fetchRequest)
                return !existingFolders.isEmpty  folder does not exist
            } catch {
                print("Error checking if folder exists: \(error.localizedDescription)")
                return false
            }
        }

        private func pasteFolder() {
            guard let folderToCopy = copyPasteManager.folderToCopy else { return }

            let newFolder = Folder(context: viewContext)
            newFolder.name = folderToCopy.name  folder
            newFolder.category = category
            newFolder.isdeleted = false
            newFolder.isFavorite = folderToCopy.isFavorite  favorite status

            do {
                try viewContext.save()

                if copyPasteManager.isMove {
                    viewContext.delete(folderToCopy)
                    try viewContext.save()
                    print("Folder moved successfully to \(category) and original folder deleted.")
                } else {
                    print("Folder copied successfully to \(category).")
                }

                copyPasteManager.folderToCopy = nil
                copyPasteManager.isMove = false
            } catch {
                print("Error pasting folder: \(error.localizedDescription)")
            }
        }

        private func moveToBin(_ folder: Folder) {
            folder.isdeleted = true
            folder.category = "Bin"

            do {
                try viewContext.save()
            } catch {
                print("Error moving folder to bin: \(error.localizedDescription)")
            }
        }

        private func restoreFolder(_ folder: Folder) {
            folder.isdeleted = false
            folder.category = category

            do {
                try viewContext.save()
            } catch {
                print("Error restoring folder: \(error.localizedDescription)")
            }
        }

        private func deleteFolderPermanently(_ folder: Folder) {
            viewContext.delete(folder)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting folder permanently: \(error.localizedDescription)")
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
                print("Bin emptied.")
            } catch {
                print("Error emptying bin: \(error.localizedDescription)")
            }
        }

        private func toggleFavoriteStatus(_ folder: Folder) {
            folder.isFavorite.toggle()
            do {
                try viewContext.save()
            } catch {
                print("Error toggling favorite status: \(error.localizedDescription)")
            }
        }

        private func startRename(_ folder: Folder) {
            isRenaming = true
            folderToRename = folder
            folderName = folder.name ?? ""
        }

        private func renameFolder(_ folder: Folder) {
            folder.name = folderName
            isRenaming = false
            folderToRename = nil

            do {
                try viewContext.save()
            } catch {
                print("Error renaming folder: \(error.localizedDescription)")
            }
        }
    }

#Preview {
    CategoryView()
}
