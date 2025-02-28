//
//  SplashView.swift
//  FileManagerPlus
//
//  Created by MANIKANDAN on 09/01/25.
//

import SwiftUI

struct SplashView: View {
    @State private var fileOffsets: [CGSize] = [CGSize(width: -200, height: 0),
                                                CGSize(width: 200, height: -150),
                                                CGSize(width: -150, height: 200)]
    @State private var folderRotation: Double = 0
    @State private var folderScale: CGFloat = 1.0
    @State private var showAppName = false
    @State private var transitionToHome = false
    @State private var gradientStart: UnitPoint = .topLeading
    @State private var gradientEnd: UnitPoint = .bottomTrailing
    @State private var showFileIcons = true
    
    let persistenceController = PersistenceController.shared
    @StateObject private var copyPasteManager = CopyPasteManager()


    var body: some View {
        if transitionToHome {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(copyPasteManager)

            
        } else {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                               startPoint: gradientStart,
                               endPoint: gradientEnd)
                    .ignoresSafeArea()
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                            gradientStart = .bottomTrailing
                            gradientEnd = .topLeading
                        }
                    }
                
                VStack(spacing: 20) {
                    ZStack {
                        Image(systemName: "folder.fill")
                            .resizable()
                            .frame(width: 120, height: 100)
                            .foregroundColor(.yellow)
                            .rotation3DEffect(.degrees(folderRotation), axis: (x: 1, y: 0, z: 0))
                            .animation(.easeInOut(duration: 0.5), value: folderRotation)
                            .scaleEffect(folderScale)
                            .animation(.spring(response: 0.8, dampingFraction: 0.5), value: folderScale)
                        
                        if showFileIcons {
                            let iconNames = ["music.note", "video.fill", "doc.fill"]
                            ForEach(0..<iconNames.count, id: \.self) { index in
                                Image(systemName: iconNames[index])
                                    .resizable()
                                    .frame(width: 40, height: 50)
                                    .foregroundColor(.clear)
                                    .overlay(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.cyan, .purple, .pink]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        .mask(
                                            Image(systemName: iconNames[index])
                                                .resizable()
                                                .frame(width: 40, height: 50)
                                        )
                                    )
                                    .offset(fileOffsets[index])
                                    .opacity(0.9) // Slightly increase visibility
                                    .animation(
                                        .easeInOut(duration: 1.0).delay(Double(index) * 0.2),
                                        value: fileOffsets[index]
                                    )
                            }
                        }
                    }
                    
                    if showAppName {
                        HStack {
                            Text("FileManager")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .transition(.opacity)
                                .animation(.easeIn(duration: 0.5), value: showAppName)
                        }
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    fileOffsets = [CGSize.zero, CGSize.zero, CGSize.zero]
                    folderRotation = -5
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    folderScale = 1.05
                }
                
                // Show app name after files animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        showAppName = true
                    }
                }
                
                // Hide file icons after 2.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        showFileIcons = false
                    }
                }
                
                // Transition to home screen after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        transitionToHome = true
                    }
                }
            }
        }
    }
}


#Preview {
    SplashView()
}
