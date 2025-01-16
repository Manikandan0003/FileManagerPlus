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

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List(colorOptions, id: \.self) { color in
                Button(action: {
                    selectedColor = color
                    onColorSelected(color)
                    dismiss()
                }) {
                    Text(color.capitalized)
                        .foregroundStyle(styleFromString(color))
                }
            }
            .navigationTitle("Select a Color")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
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
}

