//
//  ColorSelectionView.swift
//  FileManagerPlus
//
//  Created by MANIKANDAN on 15/01/25.
//

import SwiftUI

struct ColorSelectionView: View {
    @Binding var selectedColor: String
    var onColorSelected: (String) -> Void

    let colorOptions = ["red", "green", "blue", "yellow", "black", "gradient"]

    @Environment(\.dismiss) var dismiss // Used to dismiss the view

    var body: some View {
        NavigationView {
            List(colorOptions, id: \.self) { color in
                Button(action: {
                    selectedColor = color // Update selected color binding
                    onColorSelected(color) // Trigger the callback
                    dismiss() // Dismiss the view
                }) {
                    Text(color.capitalized)
                        .foregroundStyle(styleFromString(color)) // Apply the color style
                }
            }
            .navigationTitle("Select a Color")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss() // Dismiss the color selection view
                    }
                }
            }
        }
    }

    // Function to handle both single colors and gradients
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
        case "gradient": // New gradient option
            return AnyShapeStyle(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        default:
            return AnyShapeStyle(Color.blue) // Default single color
        }
    }
}
