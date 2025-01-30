//
//  InfoView.swift
//  eBay-iOS-App
//
//  Created by Jonathan Sun on 11/14/23.
//

import SwiftUI
import SwiftyJSON
import Kingfisher

struct InfoView: View {
    @Binding var itemInfo: SingleItem?
    @Binding var isLoadingInfo: Bool
    @Binding var showInfo: Bool
    
    var itemId: String
    
//    @State private var showScrollBar = false
//    @State private var itemTitle = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            if isLoadingInfo {
                ProgressView()
            }
            
            if let item = itemInfo {
//                itemTitle = item.title
//                Text(itemTitle)

                TabView {
                    ForEach(item.pictureURLs, id: \.self) { imageURL in
                        KFImage(imageURL)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .padding(.bottom, 70)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .colorScheme(.dark)
                .padding(.bottom, 10)
                
                
                Text(item.title)
                    .padding(.top, 5)
                Text("$\(item.price)")
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
                    .padding(.top, 5)
                Label("Description", systemImage: "magnifyingglass")
                    .padding(.top, 5)
                    .padding(.bottom, 30)
                
                ScrollView(.vertical) {
                    ForEach(item.itemSpecifics, id: \.name) { item in
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())], spacing: 16) {
                            Text(item.name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(item.values.first ?? "")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .overlay(
                            Divider()
                                .frame(height: 2)
                                .background(Color.gray)
                                .padding(.vertical, -8),
                            alignment: .top
                        )
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding(.horizontal, 10.0)
    }
}

#Preview {
    InfoView(itemInfo: .constant(nil), isLoadingInfo: .constant(false), showInfo: .constant(true), itemId: "")
//    InfoView()
}
