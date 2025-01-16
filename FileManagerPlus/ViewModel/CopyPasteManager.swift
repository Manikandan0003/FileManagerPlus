//
//  CopyPasteManager.swift
//  FileManagerPlus
//
//  Created by MANIKANDAN on 16/01/25.
//

import Foundation


class CopyPasteManager: ObservableObject {
    @Published var folderToCopy: Folder? = nil
    @Published var targetCategory: String? = nil
    @Published var isMove: Bool = false
}

