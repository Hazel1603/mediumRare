//
//  Settings.swift
//  Milestone 2 Submission
//
//  Created by Hazel Tan on 6/7/20.
//  Copyright © 2020 Hazel Tan. All rights reserved.
//

import SwiftUI
import Combine
import FirebaseStorage

struct Settings: View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var userProfile: UserProfile
    @ObservedObject var viewModel = RecipeViewModel()
    //@State var currentPath = ""
    //var defaultpic = defaultprofilepic().getURL()
    @State var imageURL = ""
    @State var image = Image(uiImage: UIImage())
    @State private var keyboardHeight: CGFloat = 0
    
    var updateProfile: Bool  {
        if userProfile.username == "" {
            self.userProfile.setIdToken(idToken: session.idToken)
            self.userProfile.getProfile()
            print(self.userProfile.username + " updateProfile in settings")
            //print(self.userProfile.imageFileName)
            //image = Image(uiImage: FirebaseImageView(imageURL: imageURL).image)
        }
        loadImageFromFirebase(fileName: self.userProfile.imageFileName)
        //print(self.userProfile.imageFileName)
        return true
    }
    
    func loadImageFromFirebase(fileName: String) {
        let storage = Storage.storage().reference(withPath: fileName)
        storage.downloadURL { (url, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                return
            }
            self.imageURL = "\(url!)"
        }
    }
    
    var body: some View {
        NavigationView {
            if updateProfile {
                List {
                    HStack {
                        Spacer()
                        FirebaseImageView(imageURL: imageURL)
                            //image
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .frame(width: 200, height: 200)
                        Spacer()
                    }
                    
                    Text("Hello! \(userProfile.username)").font(Font.custom("Tahoma", size: 18))
                    Text("Email: \(userProfile.email)").font(Font.custom("Tahoma", size: 18))
                
                    HStack {
                        Image(systemName: "person.circle.fill")
                        NavigationLink(destination: UpdateProfile(username: self.userProfile.username, email: self.userProfile.email)) {
                            Text("Edit profile")
                            .font(Font.custom("Tahoma", size: 18))
                        }
                    }
                    HStack {
                        Image(systemName: "gear")
                        NavigationLink(destination: ChangePassword()) {
                            Text("Change password").font(Font.custom("Tahoma", size: 18))
                        }
                    }
                    HStack {
                        Image(systemName: "folder")
                        NavigationLink(destination: Your_Recipe()) {
                            Text("Your Recipes").font(Font.custom("Tahoma", size: 18))
                        }
                    }
                    HStack {
                        Image(systemName: "heart")
                        NavigationLink(destination: Liked_Recipe()) {
                            Text("Liked Recipes").font(Font.custom("Tahoma", size: 18))
                        }
                    }
                    
                }
                    .foregroundColor(Color(red: 52/255, green: 83/255, blue: 96/255))
                    .background(Color(red: 227/255, green: 218/255, blue: 208/255))
                .navigationBarItems(trailing: Button(action: session.signOut) {
                    VStack {
                        Image(systemName: "person.circle")
                        Text("Sign Out")
                            //.foregroundColor(.blue)
                    }.foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255)).padding(.top).padding(.bottom)
                }).navigationBarTitle("Settings")
            }
        }.onAppear(perform: {
            self.loadImageFromFirebase(fileName: self.userProfile.imageFileName)
        })
    }
}

struct UpdateProfile: View {
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var session: SessionStore
    @State var username: String
    @State var email: String
    @State var password: String = ""
    @State private var showSucess = false
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var image: Image?
    @State var imageURL = ""
    @Environment(\.presentationMode) var presentationMode //to move redirect back to settings page
    
    var defaultpic = "profileIcons/defaultpic.jpg"
    let storage = Storage.storage().reference().child("profileIcons")
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    func changeProfile(profile: UserProfile) {
        userProfile.addNewProfile(profile: profile)
        session.changeEmail(email: userProfile.email)
    }
    
    var updateProfile: Bool  {
        if userProfile.username == "" {
            self.userProfile.setIdToken(idToken: session.idToken)
            self.userProfile.getProfile()
            print(userProfile.username + " updateProfile in upv")
        }
        loadImageFromFirebase(fileName: self.userProfile.imageFileName)
        return true
    }
    
    func loadImageFromFirebase(fileName: String) {
        let storage = Storage.storage().reference(withPath: fileName)
        storage.downloadURL { (url, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                return
            }
            self.imageURL = "\(url!)"
        }
    }
    
    func uploadImageToFireBase(image: UIImage, fileName: String) {
        // Create the file metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Upload the file to the path FILE_NAME
        storage.child(fileName).putData(image.jpegData(compressionQuality: 0.42)!, metadata: metadata) { (metadata, error) in
            guard let metadata = metadata else {
              // Uh-oh, an error occurred!
              print((error?.localizedDescription)!)
              return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            
            print("Upload size is \(size)")
            print("Upload success")
        }
    }
    
    func save() {

        if self.inputImage != nil {
            self.uploadImageToFireBase(image: self.inputImage!, fileName: self.session.idToken)
        }
        //self.userProfile.imageFileName = self.userProfile.imageFileName
        self.userProfile.username = self.username
        self.userProfile.email = self.email
        self.changeProfile(profile: self.userProfile)
        self.recipeUsernameChange()
        self.showSucess = true
        
    }
    
    func recipeUsernameChange() {
        if self.userProfile.yourRecipes.count > 1 {
            for recipe in self.userProfile.yourRecipes {
                if recipe != "No recipes yet" {
                    userProfile.changeRecipeAuthor(recipe: recipe, newName: self.userProfile.username)
                }
            }
            print("recipeUsernameChanged")
        }
    }
    
    var body: some View {
        VStack (alignment: .center){
            if updateProfile {
                ZStack {
                    Circle().fill(Color.secondary).frame(width: 200, height: 200)
                    if image != nil {
                        image?
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .frame(width: 200, height: 200)
                    } else {
                        FirebaseImageView(imageURL: imageURL)
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .frame(width: 200, height: 200)
                    }
                    
                }.onTapGesture {
                    self.showingImagePicker = true
                }
            }
            Group{
                HStack {
                    Text("Username")
                    TextField("\(self.userProfile.username)", text: $username)
                        .autocapitalization(.none)
                }
                HStack {
                    Text("Email")
                    TextField("\(self.userProfile.email)", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
                .font(Font.custom("Tahoma", size: 18)).padding()
            Spacer()
             
        }
        .background(Color.white)
        .alert(isPresented: $showSucess) {
            Alert(title: Text("Profile updated ^_^"), message: nil, dismissButton: .destructive(Text("Oki")){
                self.presentationMode.wrappedValue.dismiss() //redirects to settings page upon clicking oki
                })
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        }
        .navigationBarTitle("Profile")
        .navigationBarItems(trailing:
            Button(action: {
                self.save()
            }) {
                Text("Save")
            }.disabled(self.username == "" || self.email == "")
                .foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255)).padding(.top)
        )
    }
}

struct ChangePassword: View {
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var session: SessionStore
    @State var newPassword: String = ""
    @State var confirmPassword: String = ""
//    @State private var showAlert = false
    @State private var showSuccess = false
    @State private var tooshort = false
    @Environment(\.presentationMode) var presentationMode
    
    var showAlert: Bool {
        if self.newPassword == "" && self.confirmPassword == "" {
            return false
        } else {
            return self.newPassword != self.confirmPassword
        }
    }
    
    var body: some View {
        VStack {
            Text("Update your password").font(Font.custom("Tahoma", size: 18))
            Group {
                if tooshort {
                    Text("Password has to be at least 6 characters").foregroundColor(Color.red).bold()
                }
                Image(systemName: "person.circle")
                SecureField("Enter new password...", text: $newPassword, onCommit: {
                    if self.newPassword.count < 6 {
                        self.tooshort = true
                    } else {
                        self.tooshort = false
                    }
                })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                SecureField("Confirm your password...",text: $confirmPassword).textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            if showAlert {
                Text("Password unmatch").foregroundColor(Color.red).bold()
            }
            Button(action: {
                self.session.changePassword(password: self.newPassword)
                self.showSuccess = true
            }) {
                Text("Update").font(Font.custom("Raleway-SemiBold", size: 18))
                }.disabled(tooshort || showAlert)
            .alert(isPresented: $showSuccess) {
                return Alert(title: Text("Password updated ^_^"), dismissButton: .destructive(Text("Ok")){
                    self.presentationMode.wrappedValue.dismiss()
                    })
            }
        }
    }
}

struct Your_Recipe: View {
    @EnvironmentObject var userProfile: UserProfile
    
    var body: some View {
        Group {
            if userProfile.yourRecipes.count <= 1 {
                Text("No recipes yet")
                .navigationBarTitle("Your Recipes")
            } else {
                UUIDRecipe(recipeUUIDList: userProfile.yourRecipes)
                .navigationBarTitle("Your Recipes")
            }
        }
    }
}

struct Liked_Recipe: View {
    @EnvironmentObject var userProfile: UserProfile
    
    var body: some View {
        Group {
            if userProfile.likes.count <= 1 {
                Text("No likes yet")
                .navigationBarTitle("Liked Recipes")
            } else {
                UUIDRecipe(recipeUUIDList: userProfile.likes)
                    .navigationBarTitle("Liked Recipes")
            }
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
