//
//  SearchPage.swift
//  Milestone 2 Submission
//
//  Created by Hazel Tan on 23/6/20.
//  Copyright © 2020 Hazel Tan. All rights reserved.
//

import SwiftUI
import FirebaseStorage

// Filtering page
struct SearchFilter: View {
    @State var showingDetail = false
    @ObservedObject var viewModel = RecipeViewModel()
    @ObservedObject var filter = searchDetails()
    var cookware = ["Crockpot", "Slow Cooker", "Oven", "Cake Pan", "Muffin Pan"]
    @State private var selectedCookwareIndex = -1
    @State var newIng: String = ""
    @State private var redirect = false
    
    func addIngredient() {
        if newIng != "" {
            filter.inglist.append(newIng)
        }
        self.newIng = ""
    }
    
    func addCookware() {
        if selectedCookwareIndex != -1 {
            filter.cookwareList.append(cookware[selectedCookwareIndex])
        }
        self.selectedCookwareIndex = -1
    }
    
    func clearAll() {
        self.filter.inglist = [String]()
        self.filter.cookwareList = [String]()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(destination: SearchRecipeResults(filter: filter), isActive: $redirect) { EmptyView() }
            VStack {
                // New Ingredient sectioon
                VStack {
                    Text("Add new ingredient")
                        .font(.custom("Raleway-SemiBold", size: 26))
                        .foregroundColor(Color(red: 52/255, green: 83/255, blue: 96/255))
                        .padding(.top)
                    ZStack(alignment: .trailing) {
                            TextField("New ingredient", text: self.$newIng)
                                .font(.custom("Ubuntu-Light", size: 16))
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)

                        Button(action: {
                            self.addIngredient()
                            self.newIng = ""
                            self.hideKeyboard()
                        }
                            , label: {
                            Image(systemName: "plus.circle.fill")
                            .resizable()
                            .foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255))
                            .frame(width: 30, height: 30)
                            .padding()
                        })
                    }
                    .padding()
                    
                    ForEach(filter.inglist, id: \.self) { item in
                        Text(item)
                            .font(.custom("Ubuntu-Light", size: 18))
                            .padding(5)
                    }.frame(width: 300, alignment: .leading)
                    
                    Button("Clear") {
                        self.filter.inglist = [String]()
                    }.foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255)).padding(.bottom)
                }.background(Color(red: 227/255, green: 218/255, blue: 208/255).opacity(0.4).cornerRadius(10))
                .padding()
                    
                Spacer()
                
                // cookware section
                VStack {
                    Text("Add cookware")
                        .font(.custom("Raleway-SemiBold", size: 26))
                        .foregroundColor(Color(red: 52/255, green: 83/255, blue: 96/255))
                        .padding(.top)
                    
                    Button(action: {
                        self.showingDetail.toggle()
                    }) {
                        Text("Please pick a new cookware.")
                            .font(.custom("Ubuntu-Light", size: 16))
                            .frame(width: 350, height: 50, alignment: .center)
                            .background(Color.white.cornerRadius(10))
                            .padding()
                            .foregroundColor(Color.secondary.opacity(0.5))
                            
                    }.sheet(isPresented: $showingDetail) {
                        VStack (alignment: .leading){
                            HStack {
                                Picker(selection: self.$selectedCookwareIndex, label: Text("")) {
                                    ForEach(0 ..< self.cookware.count) {
                                        Text(self.cookware[$0])
                                        .font(.custom("Ubuntu-Light", size: 22))
                                    }
                                }
                                Button (action: {
                                    self.showingDetail.toggle()
                                    self.addCookware()
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .padding()
                                }
                            }
                       }
                    }
                    .buttonStyle(PlainButtonStyle())
                                        
                    ForEach(filter.cookwareList, id: \.self) { item in
                        Text(item)
                            .font(.custom("Ubuntu-Light", size: 18))
                            .padding(5)
                    }.frame(width: 300, alignment: .leading)
                    
                    Button("Clear") {
                        self.filter.cookwareList = [String]()
                    }.foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255)).padding(.bottom)
                    
                }.background(Color(red: 227/255, green: 218/255, blue: 208/255).opacity(0.4).cornerRadius(10))
                .padding()
                Spacer()
                
                Button("Clear All") {
                   self.clearAll()
               }.foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255)).padding()
                
            }.navigationBarItems(trailing:
                Button("Search") {
                    self.redirect = true
                }.foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255)))
            }
        }
    }
}

// display search results
// Argument: seacrhDetails (contains: ingList, cookwareList)
struct SearchRecipeResults: View {
    @ObservedObject var viewModel = RecipeViewModel()
    @ObservedObject var filter: searchDetails
    @State private var localSearchResults = [ingSearchResults]()
    
    var body: some View {
        List(viewModel.searchResults) {
            recipe in BroadSearchRecipeView(curr: recipe)
        }.onAppear() {
            UITableView.appearance().separatorStyle = .none
            self.viewModel.sortSearchResults(ingFilter: self.filter.inglist, cookwareFilter: self.filter.cookwareList)
            self.localSearchResults = self.viewModel.getSearchResults()
        }
    }
}

// outlook for filtered search
// Argument: ingSearchResults(contains: Recipe, ingPercentage, ingRatio, cookwarePercentage, cookwareRatio)
struct BroadSearchRecipeView: View {
    var curr: ingSearchResults
    @State var imageURL = ""
    
    func loadImageFromFirebase() {
        let storage = Storage.storage().reference(withPath: FILE_NAME)
        storage.downloadURL { (url, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                return
            }
            self.imageURL = "\(url!)"
        }
    }
    
    var imageFound: Bool {
        FILE_NAME = "tests/\(curr.recipe.id)"
        if imageURL == "" {
            loadImageFromFirebase()
        }
        return true
    }
    
    var body: some View {
        NavigationLink(destination: IndRecipeView(curr: curr.recipe)) {
            // button content
            if imageFound {
                ZStack (alignment: .bottomTrailing){
                    FirebaseImageView(imageURL: imageURL)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 375.0, height: 110.0, alignment: .center)
                        .clipShape(Rectangle())
                        .cornerRadius(15)
                        .opacity(0.4)
                        
                    VStack (alignment: .trailing){
                        Text(curr.recipe.title)
                            .font(Font.custom("Ubuntu-Light", size: 30))
                        Text("Ingredients needed: " + curr.ingCount)
                            .font(Font.custom("Tahoma", size: 18))
                        if curr.recipe.cookware[0] != "" {
                            Text("Cookware needed: " + curr.cookwareCount)
                                .font(Font.custom("Tahoma", size: 18))
                        }
                    }.padding(15)
                    .foregroundColor(Color(red: 52/255, green: 83/255, blue: 96/255))
                }
            }
        }.buttonStyle(PlainButtonStyle())
        .frame(width: 375.0, height: 110.0, alignment: .center)
            
    }
}

// stores input from user
// Argument: ingList and cookwareList
class searchDetails: ObservableObject {
    @Published var inglist = [String]()
    @Published var cookwareList = [String]()
}

struct SearchPage_Previews: PreviewProvider {
    static var previews: some View {
//        AllRecipeView()
        SearchFilter()
    }
}
