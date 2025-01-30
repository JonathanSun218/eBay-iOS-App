//
//  WishlistItem.swift
//  eBay-iOS-App
//
//  Created by Jonathan Sun on 12/5/23.
//

import Foundation

struct WishlistItem: Codable {
    let _id: String
    let imageURL: URL?
    let title: String?
    let price: Double?
    let shipping: Double?
    let zipcode: String?
    let condition: String?
    
    init(_id: String, imageURL: URL, title: String, price: Double, shipping: Double, zipcode: String, condition: String) {
        self._id = _id
        self.imageURL = imageURL
        self.title = title
        self.price = price
        self.shipping = shipping
        self.zipcode = zipcode
        self.condition = condition
    }
}
