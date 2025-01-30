//
//  FavoritesView.swift
//  eBay-iOS-App
//
//  Created by Jonathan Sun on 12/5/23.
//

import SwiftUI
import Kingfisher

struct FavoritesView: View {
    @State private var wishlist: [WishlistItem] = []
    @State private var totalWishlistPrice: Double = 0.0
    @State private var isLoadingWishlist = true
    
    var body: some View {
        NavigationStack {
            if isLoadingWishlist {
                Text("Loading...")
            } else {
                if wishlist.count != 0 {
                    List {
                        HStack {
                            Text("Wishlist total(\(wishlist.count)) items:")
                            Spacer()
                            Text("$" + String(format: "%.2f", totalWishlistPrice))
                        }
                        
                        ForEach(wishlist, id: \._id) { item in
                            HStack {
                                KFImage(item.imageURL)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 70)
                                    .cornerRadius(10.0)
                                
                                VStack(alignment: .leading) {
                                    Text(item.title!)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                    Text("$" + String(format: "%.2f", item.price!))
                                        .foregroundStyle(.blue)
                                        .fontWeight(.bold)
                                    if item.shipping == 0.0 {
                                        Text("FREE SHIPPING")
                                            .foregroundStyle(.gray)
                                    } else {
                                        Text("$" + String(format: "%.2f", item.shipping!))
                                            .foregroundStyle(.gray)
                                    }
                                    HStack {
                                        Text(item.zipcode!)
                                            .foregroundStyle(.gray)
                                        Spacer()
                                        switch item.condition {
                                        case "1000":
                                            Text("NEW")
                                                .foregroundStyle(.gray)
                                        case "2000", "2500":
                                            Text("REFURBISHED")
                                                .foregroundStyle(.gray)
                                        case "3000", "4000", "5000", "6000":
                                            Text("USED")
                                                .foregroundStyle(.gray)
                                        default:
                                            Text("NA")
                                                .foregroundStyle(.gray)
                                        }
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deleteItem)
                    }
                    .navigationTitle("Favorites")
                } else {
                    Text("No items in wishlist")
                }
            }
        }
        .onAppear {
            isLoadingWishlist = true
            APIHandler.apiHandler.getFavorites { result in
                switch result {
                case .success(let items):
                    wishlist = items
                    totalWishlistPrice = wishlist.reduce(0) { $0 + $1.price! }
                    isLoadingWishlist = false
                    print(wishlist)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    private func deleteItem(at offsets: IndexSet) {
        // Get the IDs of the items to be removed from the database
        let removedItemIDs = offsets.compactMap { wishlist[$0]._id }
        print(removedItemIDs)
        
        // Call removeFromFavorites to update the MongoDB database
        for id in removedItemIDs {
            let unwrappedID = id
            print(unwrappedID)
            APIHandler.apiHandler.removeFromFavorites(_id: unwrappedID)
        }
        // Remove items from the local wishlist
        wishlist.remove(atOffsets: offsets)
        
        // Update the total wishlist price
        updatePrice()
    }
    
    private func updatePrice() {
        totalWishlistPrice = wishlist.reduce(0) { $0 + $1.price! }
    }
}

#Preview {
    FavoritesView()
}
