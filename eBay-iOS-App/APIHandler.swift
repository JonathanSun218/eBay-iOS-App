//
//  APIHandler.swift
//  eBay-iOS-App
//
//  Created by Jonathan Sun on 11/16/23.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIHandler {
    static let apiHandler = APIHandler()
    
    let baseUrl = "http://csci571-hw3-env-1.eba-ffdamit3.us-west-1.elasticbeanstalk.com"
    
    func getCurrentLocation(completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "https://ipinfo.io/json?token=b60394b82c8000"

        AF.request(endpoint).validate().response { response in
            switch response.result {
            case .success(let data):
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any],
                          let zipCode = json["postal"] as? String else {
                        let decodingError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Postal code not found in the response"])
                        completion(.failure(decodingError))
                        return
                    }
                    completion(.success(zipCode))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getZipcodes(value: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let endpoint = "/getZipcodes"
        
        let parameters = [
            "postalcode_startsWith": value,
            "maxRows": "5",
            "username": "jsun9683",
            "country": "US"
        ]
        
        AF.request(baseUrl + endpoint, method: .get, parameters: parameters).response { response in
            do {
                switch response.result {
                case .success(let data):
                    var zipcodes: [String] = []
                    let json = try JSON(data: data!)
                    
                    if let responseData = json["postalCodes"].array {
                        for zipcode in responseData {
                            zipcodes.append(zipcode["postalCode"].stringValue)
                        }
                    } else {
                        print("JSON path incorrect.")
                    }
                    completion(.success(zipcodes))
                case .failure(let error):
                    print("Can't get zipcodes. \(error)")
                    completion(.failure(error))
                }
            } catch {
                print("Error parsing JSON: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func getList(zipcode: String, keywords: String, categoryId: String, conditions: [Bool], shipping: [Bool], distance: String, completion: @escaping (Result<[ListItem], Error>) -> Void) {
        var maxDistance = ""
        if distance == "" {
            maxDistance = "10"
        } else {
            maxDistance = distance
        }
        
        let endpoint = "/getListOfItems"
        
        var parameters = [
            "buyerPostalCode": zipcode,
            "keywords": keywords,
            "outputSelector(0)": "SellerInfo",
            "outputSelector(1)": "StoreInfo",
            "itemFilter(0).name": "HideDuplicateItems",
            "itemFilter(0).value": "true",
            "itemFilter(1).name": "MaxDistance",
            "itemFilter(1).value": maxDistance,
            "itemFilter(2).name": "LocalPickupOnly",
            "itemFilter(2).value": String(shipping[0]),
            "itemFilter(3).name": "FreeShippingOnly",
            "itemFilter(3).value": String(shipping[1]),
        ]
        
        if categoryId != "0" {
            parameters["categoryId"] = categoryId
        }
        
        if conditions[0] == false && conditions[1] == false && conditions[2] == false {
            parameters["itemFilter(4).name"] = "Condition"
            parameters["itemFilter(4).value(0)"] = "New"
            parameters["itemFilter(4).value(1)"] = "Used"
            parameters["itemFilter(4).value(2)"] = "Unspecified"
        } else {
            var count = 0
            var conditionString = "New"
            parameters["itemFilter(4).name"] = "Condition"
            for (i, condition) in conditions.enumerated() {
                switch i {
                case 1:
                    conditionString = "New"
                case 2:
                    conditionString = "Unspecified"
                default:
                    conditionString = "Used"
                }
                
                if condition {
                    parameters["itemFilter(4).value(\(count))"] = conditionString
                    count += 1
                }
            }
        }
        
//        print(parameters)
        
//        if let link = URL(string: baseUrl + endpoint)?.appendingQueryParameters(parameters) {
//            print("API URL: \(link)")
//        } else {
//            print("Error creating API URL")
//            return
//        }
        
//        let url = "http://csci571-hw3-env-1.eba-ffdamit3.us-west-1.elasticbeanstalk.com/getListOfItems?buyerPostalCode=90037&keywords=iPhone&categoryId=58058&outputSelector(0)=SellerInfo&outputSelector(1)=StoreInfo&itemFilter(0).name=HideDuplicateItems&itemFilter(0).value=true&itemFilter(1).name=MaxDistance&itemFilter(1).value=10&itemFilter(2).name=Condition&itemFilter(2).value(0)=New&itemFilter(2).value(1)=Used&itemFilter(2).value(2)=Unspecified&itemFilter(3).name=LocalPickupOnly&itemFilter(3).value=true&itemFilter(4).name=FreeShippingOnly&itemFilter(4).value=true"
        
//        AF.request(url, method: .get).response { response in
        AF.request(baseUrl + endpoint, method: .get, parameters: parameters).response { response in
            switch response.result {
            case .success(let data):
                if let responseData = data {
                    do {
                        let json = try JSON(data: responseData)
                        
                        var items: [ListItem] = []
                        
                        if let itemsArray = json["findItemsAdvancedResponse"][0]["searchResult"][0]["item"].array {
                            for item in itemsArray {
                                let itemId = item["itemId"][0].stringValue
                                let imageURL = item["galleryURL"][0].url
                                let title = item["title"][0].stringValue
                                let price = item["sellingStatus"][0]["currentPrice"][0]["__value__"].doubleValue
                                let shipping = item["shippingInfo"][0]["shippingServiceCost"][0]["__value__"].doubleValue
                                let zipcode = item["postalCode"][0].stringValue
                                let condition = item["condition"][0]["conditionId"][0].stringValue
//                                print(imageURL ?? "None")
//                                print(title)
                                items.append(ListItem(itemId: itemId, imageURL: (imageURL ?? URL(string: ""))!, title: title, price: price, shipping: shipping, zipcode: zipcode, condition: condition))
                            }
                        } else {
                            print("JSON path incorrect.")
                        }
//                        print(json)
                        completion(.success(items))
                    } catch {
                        print("Error parsing JSON: \(error)")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    func getItemInfo(itemId: String, completion: @escaping (Result<JSON, Error>) -> Void) {
        let endpoint = "/getSingleItem"
        
        let parameters = [
            "ItemID": itemId,
            "IncludeSelector": "Description,Details,ItemSpecifics"
        ]
        
//        do {
//            if let json = try JSONSerialization.jsonObject(with: Data(jsonStringReturns.utf8), options: []) as? [String: Any] {
//                swiftyJSON = JSON(json)
//            } else {
//                debugPrint("Failed to parse JSON string")
//            }
//        } catch {
//            debugPrint("Error parsing JSON string:", error)
//        }
        
        AF.request(baseUrl + endpoint, method: .get, parameters: parameters).response { response in
//            debugPrint(response)
            switch response.result {
            case .success(let data):
                if let responseData = data {
                    do {
                        let json = try JSON(data: responseData)
                        completion(.success(json))
//                        completion(.success(swiftyJSON))
                    } catch {
                        print("Error parsing JSON: \(error)")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    
    func getPhotos(itemTitle: String, completion: @escaping (Result<[URL], Error>) -> Void) {
        let endpoint = "/getPhotos"
//        print(itemTitle)
        let parameters = [
            "q": itemTitle
        ]
        
//        if let url = URL(string: baseUrl + endpoint)?.appendingQueryParameters(parameters) {
//            print("API URL: \(url)")
//        } else {
//            print("Error creating API URL")
//            return
//        }
        
//        let url = "http://csci571-hw3-env-1.eba-ffdamit3.us-west-1.elasticbeanstalk.com/getPhotos?q=Apple%20iPhone%2012%20Pro%20128%20GB%20-%20Good%20Conditions%20-All%20Colors-%20No%20Face%20ID"
        
        AF.request(baseUrl + endpoint, method: .get, parameters: parameters).response { response in
//            debugPrint(response)
            switch response.result {
            case .success(let data):
                if let responseData = data {
                    do {
                        var photos: [URL] = []
                        let json = try JSON(data: responseData)
//                        completion(.success(json))
//                        print(json["items"].arrayValue)
//                        print(json)
                        for item in json["items"].arrayValue {
                            if let thumbnailLink = item["image"]["thumbnailLink"].string,
                               let thumbnailURL = URL(string: thumbnailLink) {
                                photos.append(thumbnailURL)
                            }
                        }
//                        print(photos)
                        completion(.success(photos))
                    } catch {
                        print("Error parsing JSON: \(error)")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    func getSimilarProducts(itemId: String, completion: @escaping (Result<[SimilarProduct], Error>) -> Void) {
        let endpoint = "/getSimilarProducts"
        
        let parameters = [
            "itemId": itemId
        ]
        
        AF.request(baseUrl + endpoint, method: .get, parameters: parameters).response { response in
            switch response.result {
            case .success(let data):
                if let responseData = data {
                    do {
                        var similarProducts: [SimilarProduct] = []
                        let json = try JSON(data: responseData)
//                        print("Similar Products: \(json)")
//                        print("Similar Products: \(swiftyJSON)")
                        
                        if let itemsJSON = json["getSimilarItemsResponse"]["itemRecommendations"]["item"].array {
                            for itemJSON in itemsJSON {
                                let similarProduct = SimilarProduct(json: itemJSON)
                                similarProducts.append(similarProduct)
                            }
//                            print(similarProducts)
                        } else {
                            print("No items found")
                        }
                        completion(.success(similarProducts))
                    } catch {
                        print("Error parsing JSON: \(error)")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    func getList2(zipcode: String, keywords: String, categoryId: String, conditions: [Bool], shipping: [Bool], distance: String, completion: @escaping (Result<[ListItem3], Error>) -> Void) {
        var maxDistance = ""
        if distance == "" {
            maxDistance = "10"
        } else {
            maxDistance = distance
        }
        
        let endpoint = "/getListOfItems"
        
        var parameters = [
            "buyerPostalCode": zipcode,
            "keywords": keywords,
            "outputSelector(0)": "SellerInfo",
            "outputSelector(1)": "StoreInfo",
            "itemFilter(0).name": "HideDuplicateItems",
            "itemFilter(0).value": "true",
            "itemFilter(1).name": "MaxDistance",
            "itemFilter(1).value": maxDistance,
            "itemFilter(2).name": "LocalPickupOnly",
            "itemFilter(2).value": String(shipping[0]),
            "itemFilter(3).name": "FreeShippingOnly",
            "itemFilter(3).value": String(shipping[1]),
        ]
        
        if categoryId != "0" {
            parameters["categoryId"] = categoryId
        }
        
        if conditions[0] == false && conditions[1] == false && conditions[2] == false {
            parameters["itemFilter(4).name"] = "Condition"
            parameters["itemFilter(4).value(0)"] = "New"
            parameters["itemFilter(4).value(1)"] = "Used"
            parameters["itemFilter(4).value(2)"] = "Unspecified"
        } else {
            var count = 0
            var conditionString = "New"
            parameters["itemFilter(4).name"] = "Condition"
            for (i, condition) in conditions.enumerated() {
                switch i {
                case 1:
                    conditionString = "New"
                case 2:
                    conditionString = "Unspecified"
                default:
                    conditionString = "Used"
                }
                
                if condition {
                    parameters["itemFilter(4).value(\(count))"] = conditionString
                    count += 1
                }
            }
        }
        
//        print(parameters)
        
//        if let link = URL(string: baseUrl + endpoint)?.appendingQueryParameters(parameters) {
//            print("API URL: \(link)")
//        } else {
//            print("Error creating API URL")
//            return
//        }
        
//        let url = "http://csci571-hw3-env-1.eba-ffdamit3.us-west-1.elasticbeanstalk.com/getListOfItems?buyerPostalCode=90037&keywords=iPhone&categoryId=58058&outputSelector(0)=SellerInfo&outputSelector(1)=StoreInfo&itemFilter(0).name=HideDuplicateItems&itemFilter(0).value=true&itemFilter(1).name=MaxDistance&itemFilter(1).value=10&itemFilter(2).name=Condition&itemFilter(2).value(0)=New&itemFilter(2).value(1)=Used&itemFilter(2).value(2)=Unspecified&itemFilter(3).name=LocalPickupOnly&itemFilter(3).value=true&itemFilter(4).name=FreeShippingOnly&itemFilter(4).value=true"
        
//        AF.request(url, method: .get).response { response in
        AF.request(baseUrl + endpoint, method: .get, parameters: parameters).response { response in
            switch response.result {
            case .success(let data):
                if let responseData = data {
                    do {
                        let json = try JSON(data: responseData)
                        
                        var items: [ListItem3] = []
                        
                        if let itemsArray = json["findItemsAdvancedResponse"][0]["searchResult"][0]["item"].array {
                            for item in itemsArray {
                                let itemId = item["itemId"][0].stringValue
                                let imageURL = item["galleryURL"][0].url
                                let title = item["title"][0].stringValue
                                let price = item["sellingStatus"][0]["currentPrice"][0]["__value__"].doubleValue
                                let shipping = item["shippingInfo"][0]["shippingServiceCost"][0]["__value__"].doubleValue
                                let zipcode = item["postalCode"][0].stringValue
                                let condition = item["condition"][0]["conditionId"][0].stringValue
//                                print(imageURL ?? "None")
//                                print(title)
                                items.append(ListItem3(itemId: itemId, imageURL: (imageURL ?? URL(string: ""))!, title: title, price: price, shipping: shipping, zipcode: zipcode, condition: condition, inWishlist: false))
                            }
                        } else {
                            print("JSON path incorrect.")
                        }
//                        print(json)
                        completion(.success(items))
                    } catch {
                        print("Error parsing JSON: \(error)")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    func addToFavorites(item: WishlistItem) {
        let endpoint = "/addToWishlist"
        
        do {
            let jsonData = try JSONEncoder().encode(item)
            print(jsonData)
            AF.upload(jsonData, to: baseUrl + endpoint, method: .post, headers: ["Content-Type": "application/json"])
                .validate(contentType: ["application/json"])
                .responseDecodable(of: WishlistItem.self) { response in
                    switch response.result {
                    case .success(_):
                        print("Item added to MongoDB.")
                    case .failure(let error):
                        print("Error adding item to MongoDB: \(error)")
                    }
                }
        } catch {
            print("Error encoding item to JSON: \(error)")
        }
    }
    
    func removeFromFavorites(_id: String) {
        let endpoint = "/removeFromWishlist"  // Assuming this is the correct endpoint for removing from the wishlist
        
        let parameters = [
            "id": _id  // Use "_id" as the key for the MongoDB ID
        ]
        
        AF.request(baseUrl + endpoint, method: .delete, parameters: parameters).response { response in
            switch response.result {
            case .success:
                print("Item removed from MongoDB.")
            case .failure(let error):
                print("Error removing item from MongoDB: \(error)")
            }
        }
    }
    
    func removeFavorite(_ids: [String]) {
        let endpoint = "/removeFromWishlist"  // Assuming this is the correct endpoint for removing from the wishlist
        
        let parameters = [
            "id": _ids.first  // Use "_id" as the key for the MongoDB ID
        ]
        
        AF.request(baseUrl + endpoint, method: .delete, parameters: parameters).response { response in
            switch response.result {
            case .success:
                print("Item removed from MongoDB.")
            case .failure(let error):
                print("Error removing item from MongoDB: \(error)")
            }
        }
    }
    
    func getFavorites(completion: @escaping (Result<[WishlistItem], Error>) -> Void) {
        let endpoint = "/getWishlist"
        
        AF.request(baseUrl + endpoint, method: .get).response { response in
            switch response.result {
            case .success(let data):
                if let responseData = data {
                    do {
                        let json = try JSON(data: responseData)
                        
                        var items: [WishlistItem] = []
                        
                        if let itemsArray = json.array {
                            for item in itemsArray {
                                let itemId = item["_id"].stringValue
                                let imageURL = item["imageURL"].url
                                let title = item["title"].stringValue
                                let price = item["price"].doubleValue
                                let shipping = item["shipping"].doubleValue
                                let zipcode = item["zipcode"].stringValue
                                let condition = item["condition"].stringValue
//                                print(imageURL ?? "None")
//                                print(title)
                                items.append(WishlistItem(_id: itemId, imageURL: (imageURL ?? URL(string: ""))!, title: title, price: price, shipping: shipping, zipcode: zipcode, condition: condition))
                            }
                        } else {
                            print("JSON path incorrect.")
                        }
//                        print(json)
                        completion(.success(items))
                    } catch {
                        print("Error parsing JSON: \(error)")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension URL {
    func appendingQueryParameters(_ parameters: [String: String]) -> URL {
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
        return urlComponents.url!
    }
}
