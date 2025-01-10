//
//  HomeView.swift
//  FileManagerPlus
//
//  Created by MANIKANDAN on 10/01/25.
//

import SwiftUI
import MobileCoreServices

struct HomeView: View {
    @State private var isDocumentPickerPresented = false

    var body: some View {
        
        Text("My Files")
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
            .padding(.horizontal)
        VStack(spacing : 70){
            HStack(spacing: 100){
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
                Image(systemName: "video.circle")
                    .resizable()
                    .frame(width: 35, height: 35, alignment: .center)
                    .foregroundStyle(
                                           LinearGradient(
                                               colors: [.blue, .purple],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing
                                           )
                                       )
                Image(systemName: "headphones.circle")
                    .resizable()
                    .frame(width: 35, height: 35, alignment: .center)
                    .foregroundStyle(
                                           LinearGradient(
                                               colors: [.blue, .purple],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing
                                           )
                                       )
                
            }
            
            HStack(spacing: 100){
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
                
                Image(systemName: "trash.circle")
                    .resizable()
                    .frame(width: 35, height: 35, alignment: .center)
                    .foregroundStyle(
                                           LinearGradient(
                                               colors: [.blue, .purple],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing
                                           )
                                       )
            }
        }
        Divider()
            .padding()
        Text("Storage")
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

        Spacer()
        
    }
}

#Preview {
    HomeView()
}
