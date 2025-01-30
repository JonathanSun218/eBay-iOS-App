//
//  PhotosView.swift
//  eBay-iOS-App
//
//  Created by Jonathan Sun on 11/14/23.
//

import SwiftUI
import Kingfisher

struct PhotosView: View {
    @Binding var photos: [URL]
    
    var body: some View {
        VStack {
            HStack {
                Text("Powered by")
                Image("google")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
            }
            ScrollView(.vertical) {
                ForEach(photos, id: \.self) { photo in
                    KFImage(photo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    PhotosView(photos: .constant([]))
}
