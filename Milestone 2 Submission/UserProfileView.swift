//
//  UserProfileView.swift
//  Milestone 2 Submission
//
//  Created by Ng Jia Xin on 8/7/20.
//  Copyright © 2020 Hazel Tan. All rights reserved.
//

import SwiftUI
import Combine
import FirebaseDatabase

struct UserProfileView: View {
    
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var session: SessionStore
    
    func checks() {
        //self.userProfile.unbind()
//        userProfile.setIdToken(idToken: session.idToken)
//        userProfile.getProfile()
        if userProfile.username != "" {
            
            self.userProfile.removeBookmark(bookmark: "hello")
        }
    }
    
    var updateProfile: Bool  {
        if userProfile.username == "" {
            self.userProfile.setIdToken(idToken: session.idToken)
            self.userProfile.getProfile()
            print(userProfile.username + " updateProfile in upv")
        }
        return true
    }
    
    var body: some View {
        VStack {
            if updateProfile {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                
                Button(action: checks)
                {Text("Press me")}
                Button(action: SessionStore().signOut) {
                    Text("sign out")
                }
                Text("\(userProfile.username) hello!")
                Text("\(userProfile.email) hello!")
                Text("\(userProfile.idToken) hello!")
                Text("\(userProfile.bookmarks.count)")
            }
            //Text("nah")
        }
    }
}

class UserProfile: ObservableObject {
    
    var id: String = UUID().uuidString
    var idToken: String = ""
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var bookmarks: Array = ["No bookmarks"]
    @Published var yourRecipes: Array = ["No recipes yet"]
    @Published var likes: Array = ["No likes yet"]
    @Published var imageFileName = "profileIcons/defaultpic.jpg"
    
    private var ref = Database.database().reference()
    
//    func nsArray() -> [String: Any]{
//        let userProfile = [
//            "username": self.username,
//            "email": self.email ,
//            "bookmarks": bookmarks,
//            "yourRecipes": yourRecipes
//            ] as [String : Any]
//        return userProfile
//    }
    
    func setIdToken(idToken: String) {
        self.idToken = idToken
    }
    
    //retrieves all userProfile info at once
    func getProfile()  {
        //the first time we retrieve a profile
        //ref = self.ref.child("profiles").child(self.idToken)

        self.ref.child("profiles").child(self.idToken).observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? NSDictionary,
                let username = dict["username"] as? String,
                let email = dict["email"] as? String,
                let bookmarks = dict["bookmarks"] as? NSArray,
                let yourRecipes = dict["yourRecipes"] as? NSArray,
                let likes = dict["likes"] as? NSArray,
                let imageFileName = dict["imageFileName"] as? String
            {
                self.username = username
                self.email = email
                self.bookmarks = bookmarks as! [String]
                self.yourRecipes = yourRecipes as! [String]
                self.likes = likes as! [String]
                self.imageFileName = imageFileName
            }
        })
        
    }
    // when user first sign up, we create a new profile in firebase
    func addNewProfile(profile: UserProfile) {
        //ref = ref.child("profiles").childByAutoId()
        
        self.ref.child("profiles").child(profile.idToken).setValue(
                ["username": profile.username,
                 "email": profile.email,
                 "bookmarks": profile.bookmarks,
                 "yourRecipes": profile.yourRecipes,
                 "imageFileName": "profileIcons/\(profile.idToken)",
                 "likes": profile.likes
                ], withCompletionBlock: {error, ref in
            if error == nil {
                print("Success")
            } else {
                print(error as Any)
            }
            self.ref.child("profiles").child(profile.idToken).removeAllObservers()
        })
    }
    
//    func addYourRecipes(recipe: String) {
//
//        self.yourRecipes.append(recipe)
//
//        self.ref.child("profiles").child(self.idToken).updateChildValues(["yourRecipes": self.yourRecipes], withCompletionBlock: {error, ref in
//            if error == nil {
//                print(self.bookmarks)
//                print("Success adding recipe")
//            } else {
//                print(error as Any)
//            }
//        })
//    }
    
    func changeRecipeAuthor(recipe: String, newName: String) {
        let reff = Database.database().reference()
        
        reff.child("recipes").child(recipe).updateChildValues(["author": newName], withCompletionBlock: {error, ref in
            if error == nil {
                print("Success changing name")
            } else {
                print(error as Any)
            }
        })
    }
    func addYourRecipes(recipe: String) {
        if !self.yourRecipes.contains(recipe) {
            self.yourRecipes.append(recipe)
            
            self.ref.child("profiles").child(self.idToken).updateChildValues(["yourRecipes": self.yourRecipes], withCompletionBlock: {error, ref in
                if error == nil {
                    print(self.bookmarks)
                    print("Success adding recipe")
                } else {
                    print(error as Any)
                }
            })
        }
    }
    
    func removeRecipe(recipe: String) {
        self.ref.child("yourRecipes").queryOrderedByKey().queryEqual(toValue: recipe)
        //var index = 0
        for index in (0...(self.yourRecipes.count-1)) {
            if self.yourRecipes[index] == recipe {
                self.yourRecipes.remove(at: index)
                print("removed recipe")
                break
            }
        }
    }
    
    func addBookmark(toBeAdded: String) {
        
        //self.ref.child("profiles").child(self.idToken).removeAllObservers()
        //print(ref.description() + " this is after removal")
        
        self.bookmarks.append(toBeAdded)
        print(self.idToken)
        print(self.ref.description())
        self.ref.child("profiles").child(self.idToken).updateChildValues(["bookmarks": self.bookmarks], withCompletionBlock: {error, ref in
            if error == nil {
                print(self.bookmarks)
                print("Success adding bookmark")
            } else {
                print(error as Any)
            }
        })
    }
    
    func removeBookmark(bookmark: String) {
        self.ref.child("bookmarks").queryOrderedByKey().queryEqual(toValue: bookmark)
        //var index = 0
        for index in (0...(self.bookmarks.count-1)) {
            if self.bookmarks[index] == bookmark {
                self.bookmarks.remove(at: index)
                print("removed bookmark")
                break
            }
        }
    }
    
    func addLikes(recipe: String) {
        
        self.likes.append(recipe)
        
        self.ref.child("profiles").child(self.idToken).updateChildValues(["likes": self.likes], withCompletionBlock: {error, ref in
            if error == nil {
                print(self.bookmarks)
                print("Success adding like")
            } else {
                print(error as Any)
            }
        })
    }
    
    func removeLike(recipe: String) {
        self.ref.child("yourRecipes").queryOrderedByKey().queryEqual(toValue: recipe)
        //var index = 0
        for index in (0...(self.likes.count-1)) {
            if self.likes[index] == recipe {
                self.likes.remove(at: index)
                print("removed like")
                break
            }
        }
    }
    
    func checkUUIDExist(uuid: String, list: [String]) -> Bool {
        for m in 0...(list.count-1) {
            if list[m] == uuid {
                return true
            }
        }
        return false
    }
    
    func unbind() {
        self.ref.child("profiles").child(self.idToken).removeAllObservers()
        print("i tried...")
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView().environmentObject(UserProfile()).environmentObject(SessionStore())
    }
}
