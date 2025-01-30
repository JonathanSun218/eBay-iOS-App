//
//  ItemView2.swift
//  eBay-iOS-App
//
//  Created by Jonathan Sun on 12/4/23.
//

import SwiftUI

struct ItemView2: View {
    @Binding var item: ListItem3
    @State private var itemInfo: SingleItem?
    @State private var itemTitle = ""
    @State private var itemURL = ""
    @State private var photos: [URL] = []
    @State private var similarProducts: [SimilarProduct] = []
    @State private var isLoadingInfo = true
    @State private var showInfo = false
    
    @Binding var inFormView: Bool
    
    var itemId: String
    var itemShipping: Double
    
    var body: some View {
        TabView {
            InfoView(itemInfo: $itemInfo, isLoadingInfo: $isLoadingInfo, showInfo: $showInfo, itemId: itemId)
                .tabItem {
                    Label("Info", systemImage: "info.circle.fill")
                }
            
            ShippingView(itemInfo: $itemInfo, itemId: itemId, itemShipping: itemShipping)
                .tabItem {
                    Label("Shipping", systemImage: "shippingbox.fill")
                }
            
            PhotosView(photos: $photos)
                .tabItem {
                    Label("Photos", systemImage: "photo.stack")
                }
            
            SimilarView(similarProducts: $similarProducts)
                .tabItem {
                    Label("Similar", systemImage: "list.bullet.indent")
                }
        }
        .onAppear {
            inFormView = false
            APIHandler.apiHandler.getItemInfo(itemId: itemId) { result in
                switch result {
                case .success(let json):
                    self.itemInfo = SingleItem(json: json)
                    self.isLoadingInfo = false
                    self.showInfo = true
                    self.itemTitle = self.itemInfo?.title ?? ""
                    self.itemURL = self.itemInfo?.itemURL ?? ""
                    DispatchQueue.main.async {
                        APIHandler.apiHandler.getPhotos(itemTitle: self.itemTitle) { result in
                            switch result {
                            case .success(let links):
                                photos = links
                            case .failure(let error):
                                print("Error: \(error)")
                            }
                        }
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
            APIHandler.apiHandler.getSimilarProducts(itemId: itemId) { result in
                switch result {
                case .success(let items):
                    self.similarProducts = items
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                let shareLink = "https://www.facebook.com/sharer/sharer.php?u="
                Link(destination: URL(string: shareLink + itemURL)!, label: {
                    Image("fb")
                        .resizable()
                        .frame(width: 23, height: 23)
                })
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if item.inWishlist {
                        APIHandler.apiHandler.removeFromFavorites(_id: item.itemId)
                    } else {
                        let wishlistItem = WishlistItem(_id: item.itemId, imageURL: item.imageURL, title: item.title, price: item.price, shipping: item.shipping, zipcode: item.zipcode, condition: item.condition)
                        APIHandler.apiHandler.addToFavorites(item: wishlistItem)
                    }
                    item.inWishlist.toggle()
                    print("Button Tapped")
                }) {
                    Image(systemName: item.inWishlist ? "heart.fill" : "heart")
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

#Preview {
    ItemView2(item: .constant(ListItem3(itemId: "", imageURL: URL(string: "www.apple.com")!, title: "", price: 0.0, shipping: 0.0, zipcode: "", condition: "", inWishlist: false)), inFormView: .constant(false), itemId: "", itemShipping: 0.0)
}
