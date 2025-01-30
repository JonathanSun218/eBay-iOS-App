//
//  SheetView.swift
//  eBay-iOS-App
//
//  Created by Jonathan Sun on 12/4/23.
//

import SwiftUI

struct SheetView: View {
    @Binding var zipcodes: [String]
    @Binding var selectedZipcode: String
    @Binding var showSheet: Bool
    
    var body: some View {
        if !zipcodes.isEmpty {
            Text("Pincode Suggestions")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            List {
                ForEach(zipcodes, id: \.self) {zip in
                    Text(zip)
                        .onTapGesture {
                            selectedZipcode = zip
                            showSheet.toggle()
                        }
                }
            }
        }
//        List {
//            Text("90002")
//            Text("90003")
//            Text("90004")
//            Text("90006")
//            Text("90001")
//        }
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    SheetView(zipcodes: .constant([]), selectedZipcode: .constant(""), showSheet: .constant(true))
}
