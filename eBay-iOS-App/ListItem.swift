//
//  ListItem.swift
//  eBay-iOS-App
//
//  Created by Jonathan Sun on 11/19/23.
//

import Foundation
import Observation

struct ListItem {
    let itemId: String
    let imageURL: URL
    let title: String
    let price: Double
    let shipping: Double
    let zipcode: String
    let condition: String
    var isFavorite: Bool
    
    init(itemId: String, imageURL: URL, title: String, price: Double, shipping: Double, zipcode: String, condition: String) {
        self.itemId = itemId
        self.imageURL = imageURL
        self.title = title
        self.price = price
        self.shipping = shipping
        self.zipcode = zipcode
        self.condition = condition
        self.isFavorite = false
    }
}

@Observable class ListItem2 {
    var title: String
    var description: String
    var boolean: Bool

    init(title: String, description: String, boolean: Bool) {
        self.title = title
        self.description = description
        self.boolean = boolean
    }
}

@Observable class ListItem3 {
    var itemId: String
    var imageURL: URL
    var title: String
    var price: Double
    var shipping: Double
    var zipcode: String
    var condition: String
    var inWishlist: Bool
    
    init(itemId: String, imageURL: URL, title: String, price: Double, shipping: Double, zipcode: String, condition: String, inWishlist: Bool) {
        self.itemId = itemId
        self.imageURL = imageURL
        self.title = title
        self.price = price
        self.shipping = shipping
        self.zipcode = zipcode
        self.condition = condition
        self.inWishlist = inWishlist
    }
}
