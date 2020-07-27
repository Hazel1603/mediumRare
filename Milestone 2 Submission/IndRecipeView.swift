//
//  IndRecipeView.swift
//  Milestone 2 Submission
//
//  Created by Hazel Tan on 10/7/20.
//  Copyright © 2020 Hazel Tan. All rights reserved.
//

import SwiftUI
import FirebaseStorage

struct IndRecipeView: View {
    @EnvironmentObject var userProfile: UserProfile
    @ObservedObject var viewModel = RecipeViewModel()
    var curr: DecodedRecipe
    @State var bookmarked = false
    @State var liked = false
    @State var currentLikes = 0
    @State var IndRecipeIngList: [IndViewIng] = []
    @State var notesPresent = true
    var defaultpic = "tests/default_error.png"
    
    @State var imageURL = ""
    
    func loadImageFromFirebase() {
        let storage = Storage.storage().reference(withPath: "tests/\(self.curr.id)")
        storage.downloadURL { (url, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                return
            }
            self.imageURL = "\(url!)"
        }
    }
    
    var imageFound: Bool {
        FILE_NAME = "tests/\(curr.id).jpg"
        if imageURL == "" {
            loadImageFromFirebase()
        }
        return true
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            //Image
            FirebaseImageView(imageURL: imageURL)
                .aspectRatio(contentMode: .fill)
                .frame(width: 600, height: 350)
                .clipShape(Rectangle())
                
            
            Group {
                // Name
                HStack {
                    VStack (alignment: .leading){
                        HStack (alignment: .bottom){
                            Text(curr.title)
                                .font(Font.custom("Raleway-SemiBold", size: 36))
                            if curr.author == userProfile.username {
                                NavigationLink(destination: Trial(optionalrecipe: self.curr, loaded: false, navigationBarTitle: "Edit")){
                                    Text("Edit")
                                    .foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255))
                                        .font(.custom("Ubuntu-Light", size: 16))
                                }
                            }
                        }
                        Text(curr.author)
                            .font(Font.custom("Tahoma", size: 18))
                    }
                    Spacer()
                    HStack {
                        // Bookmark button
                        Button(action: {
                            if self.bookmarked { // remove from bookmarks list
                                self.userProfile.removeBookmark(bookmark: self.curr.id)
                            } else { // add to bookmarks
                                self.userProfile.addBookmark(toBeAdded: self.curr.id)
                            }
                            
                            self.bookmarked.toggle()
                        }) {
                            if !bookmarked {
                                Image(systemName: "bookmark")
                                    .foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255))
                                .padding(.horizontal, 10)
                            } else {
                               Image(systemName: "bookmark.fill")
                                .foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255))
                                .padding(.horizontal, 10)
                            }
                        }
                        // Like button
                        HStack {
                            Button(action: {
                                if self.liked { // remove from userProfile liked list & decrease recipe likes
                                    self.userProfile.removeLike(recipe: self.curr.id)
                                    self.viewModel.updateLikes(uuid: self.curr.id, newValue: self.currentLikes-1)
                                    self.currentLikes -= 1
                                } else { // add to liked
                                    self.userProfile.addLikes(recipe: self.curr.id)
                                    self.viewModel.updateLikes(uuid: self.curr.id, newValue: self.currentLikes+1)
                                    self.currentLikes += 1
                                }
                                self.liked.toggle()
                            }) {
                                if !liked {
                                    Image(systemName: "heart")
                                    .foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255))
                                } else {
                                   Image(systemName: "heart.fill")
                                    .foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255))
                                }
                            }
                            Text(String(self.currentLikes))
                                .font(.custom("Ubuntu-Light", size: 18))
                        }
                    }
                }.frame(width: UIScreen.screenWidth)

                // Basic Info
                HStack (alignment: .top){
                    VStack (alignment: .leading) {
                        Text("Cook Time: " + curr.cookTime)
                            .font(.custom("Ubuntu-Light", size: 18))
                        Text("Prep Time: " + curr.prepTime)
                            .font(.custom("Ubuntu-Light", size: 18))
                        Text("Difficulty: " + curr.difficulty)
                            .font(.custom("Ubuntu-Light", size: 18))
                        Text("Serving Size: " + curr.servingSize)
                        .font(.custom("Ubuntu-Light", size: 18))
                    }
                    
                    Spacer()
                    
                    VStack (alignment: .leading) {
                        Text("Cuisine: " + curr.cuisine)
                            .font(.custom("Ubuntu-Light", size: 18))
                        Text("Course: " + curr.course)
                            .font(.custom("Ubuntu-Light", size: 18))
                        if curr.cookware[0] != "" {
                            HStack {
                                Text("Cookware: ")
                                    .font(.custom("Ubuntu-Light", size: 18))
                                ForEach(0..<curr.cookware.count) { i in
                                    Text(self.curr.cookware[i])
                                        .font(.custom("Ubuntu-Light", size: 18))
                                }
                            }
                        }
                    }
                }.frame(width:UIScreen.screenWidth)
                    .padding()
                
                VStack {
                    Text("Ingredients")
                        .font(.custom("Verdana-Bold", size: 20))
                        .padding(.bottom)

                    ingListView(array: IndRecipeIngList)
                }
                
                // Steps
                VStack {
                    Text("Steps")
                        .padding(.leading)
                        .font(.custom("Verdana-Bold", size: 20))
                    
                    VStack (alignment: .leading){
                        ForEach(0..<curr.steps.count) { i in
                            HStack {
                                Text("\(i+1)  ")
                                    .font(.custom("Ubuntu-Light", size: 18))
                                Text(self.curr.steps[i])
                                    .font(.custom("Ubuntu-Light", size: 18))
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                            }.frame(width:UIScreen.screenWidth).padding(.bottom)
                        }
                        }.frame(width:UIScreen.screenWidth).padding()
                }
                
                //Notes
                VStack {
                    Text("Notes")
                        .font(.custom("Verdana-Bold", size: 20))
                    
                    VStack (alignment: .leading){
                        if self.notesPresent {
                            ForEach(0..<curr.notes.count) { curr in
                                HStack {
                                    Text("\(curr+1)  ")
                                        .font(.custom("Ubuntu-Light", size: 18))
                                    Text(self.curr.notes[curr])
                                        .font(.custom("Ubuntu-Light", size: 18))
                                    Spacer()
                                }.frame(width: UIScreen.screenWidth).padding(.bottom)
                            }
                        } else {
                            HStack {
                                Text("No Notes")
                                    .font(.custom("Ubuntu-Light", size: 18))
                                Spacer()
                            }
                        }
                    }.frame(width:UIScreen.screenWidth).padding()
                }
            }.foregroundColor(Color(red: 52/255, green: 83/255, blue: 96/255))
        }
            .onAppear(perform: {
                self.bookmarked = self.userProfile.checkUUIDExist(uuid: self.curr.id, list: self.userProfile.bookmarks)
                self.liked = self.userProfile.checkUUIDExist(uuid: self.curr.id, list: self.userProfile.likes)
                self.currentLikes = self.curr.likes
                self.IndRecipeIngList = self.curr.IndViewIngList()
                if !self.imageFound {
                    self.imageURL = self.defaultpic
                }
                self.notesPresent = (self.curr.notes[0] != "")
            })
            .edgesIgnoringSafeArea(.top)
        }
    
}

struct IndViewIng: Identifiable, Hashable {
    var id = UUID()
    var qty: String
    var ing: String
    var sub: String
}

struct ingView: View {
    var curr: IndViewIng
    
    var body: some View {
        HStack (alignment: .top){
            HStack {
                Text(curr.qty)
                    .font(.custom("Ubuntu-Light", size: 18))
                Spacer()
            }.frame(width: UIScreen.screenWidth/3)
            
            VStack (alignment: .leading){
                Text(curr.ing)
                    .font(.custom("Ubuntu-Light", size: 18))
                if curr.sub != "nil" {
                    Text("Substitute with: \(curr.sub)")
                        .font(.custom("Ubuntu-Light", size: 14))
                }
            }
            Spacer()
            
        }.frame(width: UIScreen.screenWidth)
    }
}

struct ingListView: View {
    let array: [IndViewIng]
    
    var body: some View {
        VStack {
            ForEach(array, id: \.self) {
                box in ingView(curr: box)
                    .padding(.bottom)
            }
        }
    }
}

struct IndRecipeView_Previews: PreviewProvider {
    static var previews: some View {
        IndRecipeView(curr: DecodedRecipe(id: "", title: "", author: "", cookTime: "", prepTime: "", cuisine: "", course: "", difficulty: "", steps: [], cookware: [], servingSize: "", notes: [], likes: 0, ingList: [], sub: [], ingqty: 0))
//        ingView()
    }
}

