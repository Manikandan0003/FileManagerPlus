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

    var body: some View {
        if transitionToHome {
            // Replace this with your actual home screen view
            Text("Home Screen")
                .font(.largeTitle)
                .fontWeight(.bold)
                .transition(.move(edge: .trailing))
        } else {
            ZStack {
                // Soft Background Gradient
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
                    // Folder Icon with Light Rotation
                    ZStack {
                        Image(systemName: "folder.fill")
                            .resizable()
                            .frame(width: 120, height: 100)
                            .foregroundColor(.yellow)
                            .rotation3DEffect(.degrees(folderRotation), axis: (x: 1, y: 0, z: 0))
                            .animation(.easeInOut(duration: 0.5), value: folderRotation)
                            .scaleEffect(folderScale)
                            .animation(.spring(response: 0.8, dampingFraction: 0.5), value: folderScale)
                        
                        // Animated File Icons
                        ForEach(0..<3) { index in
                            Image(systemName: "doc.fill")
                                .resizable()
                                .frame(width: 40, height: 50)
                                .foregroundColor(.white)
                                .offset(fileOffsets[index])
                                .opacity(0.8)
                                .animation(
                                    .easeInOut(duration: 1.0).delay(Double(index) * 0.2),
                                    value: fileOffsets[index]
                                )
                        }
                    }
                    
                    // App Name with Smooth Fade-In
                    if showAppName {
                        Text("FileManager Pro")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .transition(.opacity)
                            .animation(.easeIn(duration: 0.5), value: showAppName)
                    }
                }
            }
            .onAppear {
                // Animate files towards the folder
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    fileOffsets = [CGSize.zero, CGSize.zero, CGSize.zero]
                    folderRotation = -5
                }
                
                // Folder bounce
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    folderScale = 1.05
                }
                
                // Show app name after files animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        showAppName = true
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
