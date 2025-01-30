//
//  ShippingView.swift
//  eBay-iOS-App
//
//  Created by Jonathan Sun on 11/14/23.
//

import SwiftUI

struct LineView: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: 0, y: geometry.size.height / 2))
                path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2))
            }
            .stroke(Color.gray, lineWidth: 1)
        }
    }
}

struct ShippingView: View {
    @Binding var itemInfo: SingleItem?
    
    @State private var itemInfo2: SingleItem?
    
    var itemId: String
    var itemShipping: Double
    
    var body: some View {
        NavigationStack {
//            Text("ShippingView")
//            Spacer()
//                .padding(.top, 50)
            VStack(alignment: .leading) {
                LineView()
                Label("Seller", systemImage: "storefront")
                LineView()
                LazyVGrid(columns: [GridItem(.flexible(), alignment: .center), GridItem(.flexible(), alignment: .center)]) {
                    if self.itemInfo?.storeURL != nil {
                        Text("Store Name")
                        Link(self.itemInfo?.storeName ?? "None", destination: (self.itemInfo?.storeURL)!)
                    }
                    if self.itemInfo?.feedbackScore != nil {
                        Text("Feedback Score")
                        Text(self.itemInfo?.feedbackScore ?? "None")
                    }
                    if self.itemInfo?.popularity != nil {
                        Text("Popularity")
                        Text(self.itemInfo?.popularity ?? "None")
                    }
                }
                LineView()
                Label("Shipping Info", systemImage: "sailboat")
                LineView()
                LazyVGrid(columns: [GridItem(.flexible(), alignment: .center), GridItem(.flexible(), alignment: .center)]) {

                    Text("Shipping Cost")
                    if self.itemShipping == 0.0 {
                        Text("FREE")
                    } else {
                        Text("$" + String(format: "%.2f", self.itemShipping))
                    }
                    
                    if self.itemInfo?.globalShipping != "" {
                        Text("Global Shipping")
                        Text(self.itemInfo?.globalShipping ?? "None")
                    }
                    if let handlingTime = self.itemInfo?.handlingTime {
                        Text("Handling Time")
                        if handlingTime != 1 {
                            Text("\(handlingTime) days")
                        } else {
                            Text("\(handlingTime) day")
                        }
                    }
                }
                LineView()
                Label("Return Policy", systemImage: "return")
                LineView()
                LazyVGrid(columns: [GridItem(.flexible(), alignment: .center), GridItem(.flexible(), alignment: .center)]) {
                    if self.itemInfo?.returnPolicy != "" {
                        Text("Policy")
                        Text(self.itemInfo?.returnPolicy ?? "None")
                            .multilineTextAlignment(.center)
                    }
                    if self.itemInfo?.refundMode != "" {
                        Text("Refund Mode")
                        Text(self.itemInfo?.refundMode ?? "None")
                            .multilineTextAlignment(.center)
                    }
                    if self.itemInfo?.refundWithin != "" {
                        Text("Refund Within")
                        Text(self.itemInfo?.refundWithin ?? "None")
                            .multilineTextAlignment(.center)
                    }
                    if self.itemInfo?.shippingPaidBy != "" {
                        Text("Shipping Cost Paid By")
                        Text(self.itemInfo?.shippingPaidBy ?? "None")
                            .multilineTextAlignment(.center)
                    }
                }
//                .padding(.bottom, 150)
            }
            .padding(.top, 10)
            .padding(.bottom, 150)
        }
//        .onAppear {
////            inFormView = false
//            APIHandler.apiHandler.getItemInfo(itemId: itemId) { result in
//                switch result {
//                case .success(let json):
//                    self.itemInfo = SingleItem(json: json)
////                    isLoadingInfo = false
////                    showInfo = true
//                    print(self.itemInfo ?? "None")
//                case .failure(let error):
//                    print("Error: \(error)")
//                }
//            }
//        }
    }
}

#Preview {
    ShippingView(itemInfo: .constant(nil), itemId: "", itemShipping: 0.0)
}
