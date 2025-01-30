//
//  Toast.swift
//  eBay-iOS-App
//
//  Created by Jonathan Sun on 12/4/23.
//

import SwiftUI

struct Toast: View {
    var message = "Added to favorites"
    
    var body: some View {
        ZStack {
            VStack {
            Spacer()
                Text(message)
                    .padding()
                    .foregroundStyle(.white)
                    .background(.black)
                    .cornerRadius(10)
            }
        }
    }
}

#Preview {
    Toast(message: "")
}
