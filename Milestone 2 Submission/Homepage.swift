//
//  Homepage.swift
//  Milestone 2 Submission
//
//  Created by Hazel Tan on 8/7/20.
//  Copyright © 2020 Hazel Tan. All rights reserved.
//

import SwiftUI
import FirebaseStorage

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width - 30
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

struct Homepage: View {
    @ObservedObject var viewModel = RecipeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false){
                Explore()
                PopularRecipes()
            }
            .padding()
            .navigationBarTitle("Home Page")
            .navigationBarHidden(true)
            }
        .navigationBarHidden(true)
    }
}

struct Explore: View {
    @ObservedObject var viewModel = RecipeViewModel()
    
    let course: [Box] = [
        Box(id: 0, title: "Appetizer", field: "course", filterStr: "Appetizer", filterNum: 0, imageURL: "appetizer.jpg"),
        Box(id: 1, title: "Salad", field: "course", filterStr: "Salad", filterNum: 0, imageURL: "salad.png"),
        Box(id: 2, title: "Main", field: "course", filterStr: "Main", filterNum: 0, imageURL: "main.jpg"),
        Box(id: 3, title: "Dessert", field: "course", filterStr: "Dessert", filterNum: 0, imageURL: "dessert.jpg"),
        Box(id: 4, title: "Soup", field: "course", filterStr: "Soup", filterNum: 0, imageURL: "soup.jpg")
    ]
    
    let cuisine: [Box] =  [
        Box(id: 0, title: "Japanese", field: "cuisine", filterStr: "Japanese", filterNum: 0, imageURL: "japanese.jpg"),
        Box(id: 1, title: "French", field: "cuisine", filterStr: "French", filterNum: 0, imageURL: "french.jpg"),
        Box(id: 2, title: "Korean", field: "cuisine", filterStr: "Korean", filterNum: 0, imageURL: "korean.jpg"),
        Box(id: 3, title: "Italian", field: "cuisine", filterStr: "Italian", filterNum: 0, imageURL: "italian.jpg"),
        Box(id: 4, title: "Singaporean", field: "cuisine", filterStr: "Singaporean", filterNum: 0, imageURL: "singaporean.jpg")
    ]
    
    let others: [Box] = [
        Box(id: 0, title: "Under 20", field: "cookTime", filterStr: "", filterNum: 20, imageURL: "under20.jpg"),
        Box(id: 1, title: "Beginners", field: "difficulty", filterStr: "Easy", filterNum: 0, imageURL: "beginner.jpeg"),
        Box(id: 2, title: "Professional", field: "difficulty", filterStr: "Challenging", filterNum: 0, imageURL: "professional.jpg"),
    ]
    
    var body: some View  {
        VStack (alignment:.leading){
            Text("Explore")
                .font(Font.custom("Raleway-SemiBold", size: 36))
            Text("Course")
                .font(Font.custom("Ubuntu-Light", size: 22)).foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255))
            ScrollView(.horizontal, showsIndicators: false){
                HStack (spacing: 20) {
                    ForEach(course, id: \.id) { box in
                        BoxView(box: box)
                            .padding(.top, 10)
                    }
                }
            }
            Text("Cuisine")
                .font(Font.custom("Ubuntu-Light", size: 22)).foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255))
            ScrollView(.horizontal, showsIndicators: false){
                HStack (spacing: 20) {
                    ForEach(cuisine, id: \.id) { box in
                        BoxView(box: box)
                            .padding(.top, 10)
                    }
                }
            }
            Text("Others")
                .font(Font.custom("Ubuntu-Light", size: 22)).foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255))
            ScrollView(.horizontal, showsIndicators: false){
                HStack (spacing: 20) {
                    ForEach(others, id: \.id) { box in
                        BoxView(box: box)
                            .padding(.top, 10)
                    }
                }
            }
        }
    }
}

struct Box {
    var id: Int
    let title, field, filterStr: String
    let filterNum: Int
    let imageURL: String
}

struct BoxView: View {
    let box: Box
    @State var imageURL = ""
    var defaultpic = "tests/default_error.png"
    
    func loadImageFromFirebase() {
        let storage = Storage.storage().reference(withPath: FILE_NAME)
        storage.downloadURL { (url, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                return
            }
            print("Download success")
            self.imageURL = "\(url!)"
        }
    }
    
    var imageFound: Bool {
        FILE_NAME = "HomepageIcons/\(self.box.imageURL)"
        if imageURL == "" {
            loadImageFromFirebase()
        }
        return true
    }
    
    
    var body: some View {
        NavigationLink(destination: RecipeView(curr: box)){
//        NavigationLink(destination: Text(box.filterStr)) {
            Group {
                VStack {
                    ZStack {
                        FirebaseImageView(imageURL: imageURL)
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .frame(width:50, height:50)
                            .cornerRadius(12)
                        Circle()
                            .frame(width:50, height:50)
                            .foregroundColor(Color.white)
                            .opacity(0.1)
                            .shadow(color: Color.black, radius: 8)
                        
                    }
                    Text(box.title)
                        .font(Font.custom("Ubuntu-Light", size: 16)).foregroundColor(Color(red: 52/255, green: 83/255, blue: 96/255))
                }
            }
        }.buttonStyle(PlainButtonStyle())
        .onAppear(perform: {
            if self.imageFound {
                self.imageURL = self.box.imageURL
            } else {
                self.imageURL = self.defaultpic
            }
        })
    }
}

// displays all recipes in alphabetical order
struct RecipeView: View {
    @ObservedObject var viewModel = RecipeViewModel()
    var curr: Box
    
    var body: some View {
        List(viewModel.recipes) { recipe in
            BroadAllRecipeView(curr: recipe)
        }.onAppear() {
            UITableView.appearance().separatorStyle = .none
            self.viewModel.homepageFilter(field: self.curr.field, filterStr: self.curr.filterStr, filterNum: self.curr.filterNum)
        }.navigationBarTitle(curr.title)
    }
}

// outlook for unfiltered search
// Argument: Recipe
struct BroadAllRecipeView: View {
    var curr: DecodedRecipe
    @State var imageURL = ""
    
    func loadImageFromFirebase() {
        let storage = Storage.storage().reference(withPath: FILE_NAME)
        storage.downloadURL { (url, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                return
            }
            print("Download success")
            self.imageURL = "\(url!)"
        }
    }
    
    var imageFound: Bool {
        FILE_NAME = "tests/\(curr.id)"
        if imageURL == "" {
            loadImageFromFirebase()
        }
        return true
    }
    
    var body: some View {
        NavigationLink(destination: IndRecipeView(curr: curr)) {
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
                        Text(curr.title)
                            .font(Font.custom("Ubuntu-Light", size: 30)).bold()
                        Text("Ingredients needed: " + String(curr.ingqty))
                            .font(Font.custom("Tahoma", size: 18))
                    }.padding(15).foregroundColor(Color(red: 52/255, green: 83/255, blue: 96/255))
                }
            }
        }.buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .frame(width: 375, height: 110)
            
    }
}

struct PopularRecipes: View {
    @ObservedObject var viewModel = RecipeViewModel()
    
    var body: some View {
        VStack (alignment: .leading){
            Text("Popular Recipes")
                .font(Font.custom("Raleway-SemiBold", size: 36))
            
            VStack {
                ForEach(viewModel.recipes, id: \.id) { recipe in
                    BroadAllRecipeView(curr: recipe)
                }
            }.onAppear() {
                UITableView.appearance().separatorStyle = .none
                self.viewModel.orderByLikes()
            }
            Spacer()
        }
    }
}

struct Homepage_Previews: PreviewProvider {
    static var previews: some View {
        Homepage()
    }
}
