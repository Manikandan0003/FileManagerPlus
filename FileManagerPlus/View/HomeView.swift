//
//  HomeView.swift
//  FileManagerPlus
//
//  Created by MANIKANDAN on 10/01/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var copyPasteManager: CopyPasteManager


    var body: some View {
        NavigationStack{
            VStack{
            Text("My Files")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.primary)
            HStack{
                Image(.search)
                    .resizable()
                    .frame(width: 20, height: 20)
                
                Image(.sideicon)
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal)
            .padding(.horizontal)
            
            Text("Categaries")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 25, weight: .bold))
                .padding(.horizontal)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            VStack(spacing : 20){
                HStack(spacing: 40){
                    NavigationLink(destination: PhotoListView())
                    {
                        VStack{
                            Image(systemName: "photo.circle")
                                .resizable()
                                .frame(width: 35, height: 35, alignment: .center)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("Photos")
                                .frame(width: 100, height: 35, alignment: .center)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                .font(.system(size: 15, weight: .semibold))

                        }}
                    
                    
                    NavigationLink(destination: DocumentListView())
                    {
                        VStack{
                            Image(systemName: "doc.circle")
                                .resizable()
                                .frame(width: 35, height: 35, alignment: .center)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("Documents")
                                .frame(width: 100, height: 35, alignment: .center)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                .font(.system(size: 15, weight: .semibold))

                            
                        }
                        
                    }
                    NavigationLink(destination: FolderView(category: "Downloads").environmentObject(copyPasteManager))
                    {
                        VStack{
                            Image(systemName: "arrow.down.circle")
                                .resizable()
                                .frame(width: 35, height: 35, alignment: .center)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("Downloads")
                                .frame(width: 100, height: 35, alignment: .center)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                .font(.system(size: 15, weight: .semibold))
                        }
                    }
                }
                
                
                
//                Divider()
                    .padding()
                
                NavigationLink(destination: FolderView(category: "My Files").environmentObject(copyPasteManager)) {
                    HStack {
                        Text("File Management")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .opacity(0.1)
                            )
                   )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(UIColor.systemGray4), lineWidth: 1) 
                    )
                }

                
                
            }
            Spacer()
        }
            .padding(.top,100)


        }
    }
}

#Preview {
    HomeView()
        .environmentObject(CopyPasteManager())
}
