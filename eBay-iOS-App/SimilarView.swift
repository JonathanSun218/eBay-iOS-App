//
//  SimilarView.swift
//  eBay-iOS-App
//
//  Created by Jonathan Sun on 11/14/23.
//

import SwiftUI
import SwiftyJSON
import Kingfisher

struct SimilarView: View {
    @Binding var similarProducts: [SimilarProduct]
    
//    @State private var sortedSimilarProducts: [SimilarProduct] = similarProducts
    @State private var sortOption = "default"
    @State private var sortOrder = "ascending"
    
    // “How do I sort an array by title and price in ascending order” prompt (8 lines). ChatGPT, 4 Dec. version, OpenAI, 4 Dec. 2023, chat.openai.com/chat.
    private var sortedSimilarProducts: [SimilarProduct] {
        switch (sortOption, sortOrder) {
        case ("sortByName", "ascending"):
            return similarProducts.sorted { $0.title ?? "" < $1.title ?? "" }
        case ("sortByName", "descending"):
            return similarProducts.sorted { $0.title ?? "" > $1.title ?? "" }
        case ("sortByPrice", "ascending"):
            return similarProducts.sorted { $0.price ?? -0.01 < $1.price ?? -0.01 }
        case ("sortByPrice", "descending"):
            return similarProducts.sorted { $0.price ?? -0.01 > $1.price ?? -0.01 }
        case ("sortByDaysLeft", "ascending"):
            return similarProducts.sorted { $0.daysLeft ?? -1 < $1.daysLeft ?? -1 }
        case ("sortByDaysLeft", "descending"):
            return similarProducts.sorted { $0.daysLeft ?? -1 > $1.daysLeft ?? -1 }
        case ("sortByShipping", "ascending"):
            return similarProducts.sorted { $0.shipping ?? -0.01 < $1.shipping ?? -0.01 }
        case ("sortByShipping", "descending"):
            return similarProducts.sorted { $0.shipping ?? -0.01 > $1.shipping ?? -0.01 }
        default:
            return similarProducts
        }
    }
//    private var sortedSimilarProducts: [SimilarProduct] {
//        switch (sortOption, sortOrder) {
//        case ("sortByName", "ascending"):
//            return similarProducts.sorted { $0.title ?? "" < $1.title ?? "" }
//        case ("sortByName", "descending"):
//            return similarProducts.sorted { $0.title ?? "" > $1.title ?? "" }
//        case ("sortByPrice", "ascending"):
//            return similarProducts.sorted { Double($0.price ?? "0") ?? 0 < Double($1.price ?? "0") ?? 0 }
//        case ("sortByPrice", "descending"):
//            return similarProducts.sorted { Double($0.price ?? "0") ?? 0 > Double($1.price ?? "0") ?? 0 }
//        case ("sortByDaysLeft", "ascending"):
//            return similarProducts.sorted { $0.daysLeft ?? -1 < $1.daysLeft ?? -1 }
//        case ("sortByDaysLeft", "descending"):
//            return similarProducts.sorted { $0.daysLeft ?? -1 > $1.daysLeft ?? -1 }
//        case ("sortByShipping", "ascending"):
//            return similarProducts.sorted { Double($0.shipping ?? "0") ?? 0 < Double($1.shipping ?? "0") ?? 0 }
//        case ("sortByShipping", "descending"):
//            return similarProducts.sorted { Double($0.shipping ?? "0") ?? 0 > Double($1.shipping ?? "0") ?? 0 }
//        default:
//            return similarProducts
//        }
//    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Sort By")
                    .fontWeight(.bold)
                    .font(.title3)
                
                Picker("Category", selection: $sortOption) {
                    Text("Default").tag("default")
                    Text("Name").tag("sortByName")
                    Text("Price").tag("sortByPrice")
                    Text("Days Left").tag("sortByDaysLeft")
                    Text("Shipping").tag("sortByShipping")
                }
                .pickerStyle(SegmentedPickerStyle())
                
                if sortOption != "default" {
                    Text("Order")
                        .fontWeight(.bold)
                        .font(.title3)
                        .padding(.top)
                    
                    Picker("Category", selection: $sortOrder) {
                        Text("Ascending").tag("ascending")
                        Text("Descending").tag("descending")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .padding(.horizontal)
            .padding(.bottom)

            ScrollView(.vertical) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 170))], alignment: .center, spacing: 20) {
                    ForEach(sortedSimilarProducts, id: \.self) { similarProduct in
                        VStack {
                            KFImage(similarProduct.imageURL)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 160, height: 160)
                                .cornerRadius(10.0)
                                .padding(.top, 10)
                            
                            VStack(alignment: .trailing) {
                                Text(similarProduct.title ?? "None")
                                    .lineLimit(2)
                                    .padding(.top, 5)
                                    .frame(width: 145)
                                
                                HStack {
                                    Text("$" + String(format: "%.2f", similarProduct.shipping ?? -0.01))
                                        .font(.footnote)
                                    Spacer()
                                    Text("\(similarProduct.daysLeft ?? -1) days left")
                                        .font(.footnote)
                                }
                                .frame(width: 145)
                                
                                Text("$" + String(format: "%.2f", similarProduct.price ?? "None"))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.blue)
                                    .padding(.vertical, 5)
                                    
                                    
                            }
                            .padding()
                            .frame(width: 170)
                        }
                        .background(Color(.systemGray6))
                        .border(.gray, width: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.gray, lineWidth: 2)
                        )
                        .cornerRadius(17.0)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SimilarView(similarProducts: .constant([]))
}
