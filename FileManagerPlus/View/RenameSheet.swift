//
//  RenameSheet.swift
//  FileManagerPlus
//
//  Created by MANIKANDAN on 16/01/25.
//

import SwiftUI


struct RenameSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    var photo: Folder?
    @Binding var newName: String
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Rename Photo")
                    .font(.headline)
                
                TextField("Enter new name", text: $newName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                HStack {
                    Button("Cancel") {
                        isVisible = false
                    }
                    .padding()
                    
                    Spacer()
                    Button("Save") {
                        if let photo = photo {
                            photo.name = newName
                            do {
                                try viewContext.save()
                            } catch {
                                print("Error saving renamed photo: \(error)")
                            }
                        }
                        isVisible = false
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 20)
            
            Spacer()
        }
        .background(Color.black.opacity(0.2).edgesIgnoringSafeArea(.all))
    }
}

