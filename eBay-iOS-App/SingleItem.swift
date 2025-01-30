//
//  SingleItem.swift
//  eBay-iOS-App
//
//  Created by Jonathan Sun on 11/28/23.
//

import Foundation
import SwiftyJSON

struct SingleItem {
    let itemURL: String
    
    // InfoView variables
    let pictureURLs: [URL]
    let title: String
    let price: String
    let itemSpecifics: [ItemSpecific]
    
    // ShippingView variables
    let storeName: String?
    let storeURL: URL?
    let feedbackScore: String?
    let popularity: String?
    
//    let shippingCost: String
    let globalShipping: String?
    let handlingTime: Int?
    
    let returnPolicy: String?
    let refundMode: String?
    let refundWithin: String?
    let shippingPaidBy: String?
    
    init(json: JSON) {
        itemURL = json["Item"]["ViewItemURLForNaturalSearch"].stringValue
        
        // InfoView initializations
        pictureURLs = json["Item"]["PictureURL"].arrayValue.compactMap { URL(string: $0.stringValue) }
        title = json["Item"]["Title"].stringValue
        price = String(format: "%.2f", json["Item"]["CurrentPrice"]["Value"].doubleValue)
        itemSpecifics = json["Item"]["ItemSpecifics"]["NameValueList"].arrayValue.compactMap { nameValueJSON in
            let name = nameValueJSON["Name"].stringValue
            let values = nameValueJSON["Value"].arrayValue.compactMap { $0.stringValue }
            return ItemSpecific(name: name, values: values)
        }
        
        // ShippingView initializations
        storeName = json["Item"]["Storefront"]["StoreName"].stringValue
        storeURL = json["Item"]["Storefront"]["StoreURL"].url
        feedbackScore = String(json["Item"]["Seller"]["FeedbackScore"].doubleValue)
        popularity = String(format: "%.2f", json["Item"]["Seller"]["PositiveFeedbackPercent"].doubleValue)
        
        globalShipping = json["Item"]["GlobalShipping"].boolValue ? "Yes" : "No"
        handlingTime = json["Item"]["HandlingTime"].intValue
        
        returnPolicy = json["Item"]["ReturnPolicy"]["ReturnsAccepted"].stringValue
        refundMode = json["Item"]["ReturnPolicy"]["Refund"].stringValue
        refundWithin = json["Item"]["ReturnPolicy"]["ReturnsWithin"].stringValue
        shippingPaidBy = json["Item"]["ReturnPolicy"]["ShippingCostPaidBy"].stringValue
    }
}

struct ItemSpecific {
    let name: String
    let values: [String]
}
