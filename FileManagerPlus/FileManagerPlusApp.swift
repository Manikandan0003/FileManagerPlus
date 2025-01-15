//
//  FileManagerPlusApp.swift
//  FileManagerPlus
//
//  Created by MANIKANDAN on 09/01/25.
//

import SwiftUI

@main
struct FileManagerPlusApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var copyPasteManager = CopyPasteManager()

    var body: some Scene {
        WindowGroup {
            SplashView()

            
        }
    }
}

//@main
//struct FileManagerPlusApp: App {
//    let persistenceController = PersistenceController.shared
//    @StateObject private var copyPasteManager = CopyPasteManager()
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
//                .environmentObject(copyPasteManager)
//        }
//    }
//}
