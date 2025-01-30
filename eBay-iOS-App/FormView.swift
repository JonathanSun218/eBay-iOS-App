//
//  FormView.swift
//  eBay-iOS-App
//
//  Created by Jonathan Sun on 11/14/23.
//

import SwiftUI
import Observation
import Kingfisher

struct FormView: View {
    @State private var keyword = ""
    @State private var categoryID = "0"
    @State private var conditions: [Bool] = [false, false, false]
    @State private var shipping: [Bool] = [false, false]
    @State private var distance = ""
    @State private var currentLocation = false
    @State private var currentZipcode = ""
    @State private var zipcode = ""
    @State private var zipcodes: [String] = []
    @State private var itemsList: [ListItem3] = []
    
    @State private var showToast = false
    @State private var message = ""
    
    @State private var inFormView = true
    @State private var isLoadingList = false
    @State private var showList = false
    @State private var showSheet = false
    
    let randomIndex = Int.random(in: 0..<100)
    
    private var debouncer: Debouncer = Debouncer(delay: 0.5)
    
    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    Text("Keyword:")
                    TextField("Required", text: $keyword)
                }
                
                Picker("Category", selection: $categoryID) {
                    Text("All").tag("0")
                    Text("Art").tag("550")
                    Text("Baby").tag("2984")
                    Text("Books").tag("267")
                    Text("Clothing, Shoes, & Accessories").tag("11450")
                    Text("Computers/Tablets & Networking").tag("58058")
                    Text("Health & Beauty").tag("26395")
                    Text("Music").tag("11233")
                    Text("Video Games & Consoles").tag("1249")
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.vertical, 5)
                
                VStack(alignment: .leading) {
                    Text("Condition")
                        .padding(.bottom, 5.0)
                    HStack {
                        Spacer()
                        Image(systemName: conditions[0] ? "checkmark.square.fill" : "square")
                            .foregroundStyle(conditions[0] ? .blue : .gray)
                            .onTapGesture {
                                conditions[0].toggle()
                            }
                        Text("Used")
                        Spacer()
                        Image(systemName: conditions[1] ? "checkmark.square.fill" : "square")
                            .foregroundStyle(conditions[1] ? .blue : .gray)
                            .onTapGesture {
                                conditions[1].toggle()
                            }
                        Text("New")
                        Spacer()
                        Image(systemName: conditions[2] ? "checkmark.square.fill" : "square")
                            .foregroundStyle(conditions[2] ? .blue : .gray)
                            .onTapGesture {
                                conditions[2].toggle()
                            }
                        Text("Unspecified")
                        Spacer()
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Shipping")
                        .padding(.bottom, 5.0)
                    HStack {
                        Spacer()
                        Image(systemName: shipping[0] ? "checkmark.square.fill" : "square")
                            .foregroundStyle(shipping[0] ? .blue : .gray)
                            .onTapGesture {
                                shipping[0].toggle()
                            }
                        Text("Pickup")
                        Spacer()
                        Image(systemName: shipping[1] ? "checkmark.square.fill" : "square")
                            .foregroundStyle(shipping[1] ? .blue : .gray)
                            .onTapGesture {
                                shipping[1].toggle()
                            }
                        Text("Free Shipping")
                        Spacer()
                    }
                }
                
                HStack {
                    Text("Distance:")
                    TextField("10", text: $distance)
                }
                
                VStack(alignment: .leading) {
                    Toggle("Custom Location", isOn: $currentLocation)
                    
                    if currentLocation {
                        HStack {
                            Text("Zipcode")
                            TextField("Required", text: $zipcode)
                        }
                    }
                }
                
                HStack {
                    Spacer()
                    Button {
                        if keyword.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                            message = "Keyword is mandatory"
                            showToast.toggle()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                showToast.toggle()
                            }
                        } else {
                            isLoadingList = true
                            showList = false
                            if zipcode == "" {
                                zipcode = currentZipcode
                            }
                            
    #if os(iOS)
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    #elseif os(macOS)
                            NSApp.keyWindow?.makeFirstResponder(nil)
    #endif
                            
                            APIHandler.apiHandler.getList2(zipcode: zipcode, keywords: keyword, categoryId: categoryID, conditions: conditions, shipping: shipping, distance: distance) { result in
                                switch result {
                                case .success(let listItems):
                                    itemsList = listItems
                                    isLoadingList = false
                                    showList = true
                                    if !currentLocation {
                                        zipcode = ""
                                    }
                                case .failure(let error):
                                    print("API call failed with error: \(error)")
                                }
                            }
                        }
                    } label: {
                        Text("Submit")
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                    Button {
                        keyword = ""
                        categoryID = "0"
                        conditions = [false, false, false]
                        shipping = [false, false]
                        distance = ""
                        currentLocation = false
                        zipcode = ""
                        zipcodes = []
                        itemsList = []
                        
                        showToast = false
                        message = ""
                        
                        inFormView = true
                        isLoadingList = false
                        showList = false
                        showSheet = false
                    } label : {
                        Text("Clear")
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                
                if isLoadingList {
                    Section {
                        Text("Results")
                            .font(.title)
                            .fontWeight(.bold)
                        HStack {
                            Spacer()
                            ProgressView("Please wait...")
                                .progressViewStyle(CircularProgressViewStyle()).id(UUID())
                            Spacer()
                        }
                    }
                }
                
                if showList {
                    Section {
                        if itemsList.count != 0 {
                            Text("Results")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            List {
                                ForEach(itemsList.indices, id: \.self) { index in
                                    HStack {
                                        NavigationLink(destination: ItemView2(item: $itemsList[index], inFormView: $inFormView, itemId: itemsList[index].itemId, itemShipping: itemsList[index].shipping)) {
                                            KFImage(itemsList[index].imageURL)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 70, height: 70)
                                                .cornerRadius(10.0)
                                            
                                            VStack(alignment: .leading) {
                                                Text(itemsList[index].title)
                                                    .lineLimit(1)
                                                    .truncationMode(.tail)
                                                Text("$" + String(format: "%.2f", itemsList[index].price))
                                                    .foregroundStyle(.blue)
                                                    .fontWeight(.bold)
                                                if itemsList[index].shipping == 0.0 {
                                                    Text("FREE SHIPPING")
                                                        .foregroundStyle(.gray)
                                                } else {
                                                    Text("$" + String(format: "%.2f", itemsList[index].shipping))
                                                        .foregroundStyle(.gray)
                                                }
                                                HStack {
                                                    Text(itemsList[index].zipcode)
                                                        .foregroundStyle(.gray)
                                                    Spacer()
                                                    switch itemsList[index].condition {
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
                                            
                                            Button(action: {
                                                if itemsList[index].inWishlist {
                                                    APIHandler.apiHandler.removeFromFavorites(_id: itemsList[index].itemId)
                                                } else {
                                                    let wishlistItem = WishlistItem(_id: itemsList[index].itemId, imageURL: itemsList[index].imageURL, title: itemsList[index].title, price: itemsList[index].price, shipping: itemsList[index].shipping, zipcode: itemsList[index].zipcode, condition: itemsList[index].condition)
                                                    APIHandler.apiHandler.addToFavorites(item: wishlistItem)
                                                }
                                                itemsList[index].inWishlist.toggle()
                                                message = itemsList[index].inWishlist ? "Added to favorites" : "Removed from favorites"
                                                showToast.toggle()
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                    showToast.toggle()
                                                }
                                                print(itemsList[index])
                                            }) {
                                                Image(systemName: itemsList[index].inWishlist ? "heart.fill" : "heart")
                                                    .foregroundStyle(.red)
                                                    .font(.system(size: 25))
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                            }
                        } else {
                            Text("Results")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("No results found.")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .navigationTitle("Product Search")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: FavoritesView()) {
                        Image(systemName: "heart.circle")
                            .foregroundStyle(.blue)
                    }
                }
            }
            .overlay(
                ZStack {
                    if showToast {
                        Toast(message: message)
                    }
                }
            )
            .sheet(isPresented: $showSheet) {
                SheetView(zipcodes: $zipcodes, selectedZipcode: $zipcode, showSheet: $showSheet)
            }
            .onAppear {
                APIHandler.apiHandler.getCurrentLocation { result in
                    switch result {
                    case .success(let postalCode):
                        currentZipcode = postalCode
                        //                        print(currentZipcode)
                    case .failure(let error):
                        print("Didn't get zipcode: \(error)")
                    }
                    
                    debouncer.action = {
                        //                        print(zipcode)
                        if zipcode != "" && zipcode.count < 5 {
                            APIHandler.apiHandler.getZipcodes(value: zipcode) { result in
                                switch result {
                                case .success(let data):
                                    zipcodes = data
                                    DispatchQueue.main.async {
                                        showSheet.toggle()
                                    }
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        }
                    }
                }
            }
            .onChange(of: zipcode) {
                self.debouncer.call()
            }
        }
    }
}

@Observable class Debouncer {
    private let delay: TimeInterval
    private var timer: Timer?
    
    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    func call() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            // Call the provided closure when the timer fires
            self.action()
        }
    }
    
    var action: () -> Void = {}
}

#Preview {
    FormView()
    //        .modelContainer(for: Item.self, inMemory: true)
}
