//
//  SimilarProduct.swift
//  eBay-iOS-App
//
//  Created by Jonathan Sun on 12/2/23.
//

import Foundation
import SwiftyJSON

struct SimilarProduct: Hashable {
    let imageURL: URL?
    let title: String?
    let price: Double?
    let shipping: Double?
    let daysLeft: Int?
    
    init(json: JSON) {
        let pattern = #"(?<=P)(.*?)(?=D)"#
        
        imageURL = json["imageURL"].url
        title = json["title"].stringValue
        price = json["buyItNowPrice"]["__value__"].doubleValue
        shipping = json["shippingCost"]["__value__"].doubleValue

        if let match = json["timeLeft"].stringValue.range(of: pattern, options: .regularExpression) {
            daysLeft = Int(json["timeLeft"].stringValue[match])
        } else {
            daysLeft = nil
        }
    }
}
