//
//  AuthView.swift
//  Trial
//
//  Created by Ng Jia Xin on 5/7/20.
//  Copyright © 2020 Ng Jia Xin. All rights reserved.
//

import SwiftUI
import FirebaseStorage
import Combine

struct AuthView: View {
    
    var body: some View {
        NavigationView {
            SignInView()
        }
    }
}

let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)

struct SignInView: View {
    
    @State var email: String = ""
    @State var password: String = ""
    @State var error: String = ""
    @EnvironmentObject var session: SessionStore
    @State var authenticationDidFail: Bool = false
    @State var authenticationDidSucceed: Bool = false
    @EnvironmentObject var userProfile: UserProfile
    @ObservedObject var keyboardResponder = KeyboardResponder()
    
    func signIn() {
        session.signIn(email: email, password: password) { (result, error) in
            if let error = error {
                self.error = error.localizedDescription
                self.authenticationDidFail = true
            } else {
                self.authenticationDidSucceed = true
                self.authenticationDidFail = false
                self.userProfile.setIdToken(idToken: self.session.idToken)
                self.userProfile.getProfile()
                self.email = ""
                self.password = ""
                self.error = ""
                print("profile gotten >:( at sign in")
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                WelcomeText()
                UserImage()
                EmailTextField(email: $email)
                PasswordSecureField(password: $password)
                if error != "" {
                    Text(error)
                        //.offset(y: -10)
                        .foregroundColor(.red)
                }
                Button(action: signIn
                ) {
                    LoginButtonContent()
                }
                
                Spacer()
                
                NavigationLink(destination: SignUpView(keyboardResponder: self.keyboardResponder)) {
                    HStack {
                        Text("New user?")
                            .font(.system(size: 14, weight: .light))
                            .foregroundColor(.primary)
                        
                        Text("Create an account").font(.system(size: 14, weight: .semibold)).foregroundColor(.secondary)
                    }
                }
            }.offset(y: -keyboardResponder.currentHeight*0.9)
            .padding()
        }
    }
}

struct SignUpView: View {
    @State var username: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var error: String = ""
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var userProfile: UserProfile
    @ObservedObject var keyboardResponder: KeyboardResponder
    
    @State private var image: Image?
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false
    let storage = Storage.storage().reference().child("profileIcons")
    
    //this fileName refers to the name of the file excl. profileIcons
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
    //no need to assign imageFileName as it is already initialised
    func signUp() {
        session.signUp(email: email, password: password, displayName: username) { (result, error) in
            if let error = error {
                self.error = error.localizedDescription
            } else {
                self.userProfile.username = self.username
                self.userProfile.email = self.email
                self.userProfile.setIdToken(idToken: self.session.idToken)
                self.email = ""
                self.password = ""
                
                if self.inputImage != nil {
                    let fileName = self.session.idToken
                    self.uploadImageToFireBase(image: self.inputImage!, fileName: fileName)
                    self.userProfile.imageFileName = "profileIcons/\(fileName)"
                }
                self.userProfile.addNewProfile(profile: self.userProfile)
            }
        }
//        if session.idToken != "" {
//            self.userProfile.setIdToken(idToken: session.idToken)
//            self.userProfile.username = self.username
//            self.userProfile.email = self.email
//            print("success setting idtoken at signUp")
//        }
        //idtoken to be changed to email uid
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    var body: some View {
        ScrollView (.vertical) {
            VStack {
                Text("Create Account")
                    .font(.custom("Raleway-SemiBold", size: 36))
                    .foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255))
                Text("Sign up to get started")
                    .font(.custom("Ubuntu-Light", size: 18))
                    .foregroundColor(.gray)
                    .foregroundColor(Color(red: 227/255, green: 218/255, blue: 208/255))
                
                VStack(spacing: 18) {
                    ZStack {
                        Circle().fill(Color(red: 52/255, green: 83/255, blue: 96/255)).frame(width: 200, height: 200)
                        if image != nil {
                            image?
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 350, height: 300)
                            .clipShape(Circle())
                        } else {
                            Text("Tap to select an image")
                                .foregroundColor(.white)
                                .font(.custom("Ubuntu-Light", size: 18))
                        }
                    }.onTapGesture {
                        self.showingImagePicker = true
                    }.padding()
                    
                    Group {
                    TextField("Username", text: $username)
                        .font(.custom("Ubuntu-Light", size: 18))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 5.0)
                        .strokeBorder(Color(red: 227/255, green: 218/255, blue: 208/255), lineWidth: 1))
                        .autocapitalization(.none)
                    
                    TextField("Email", text: $email)
                        .font(.custom("Ubuntu-Light", size: 18))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 5.0)
                        .strokeBorder(Color(red: 227/255, green: 218/255, blue: 208/255), lineWidth: 1))
                    
                    SecureField("Password", text: $password)
                        .font(.custom("Ubuntu-Light", size: 18))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 5.0)
                        .strokeBorder(Color(red: 227/255, green: 218/255, blue: 208/255), lineWidth: 1))
                    }
                }
                .padding(.vertical, 64)
                
                Button(action: signUp) {
                    Text("Sign Up")
                    .font(.custom("Ubuntu-Light", size: 20))
                    .foregroundColor(Color(red: 52/255, green: 83/255, blue: 96/255))
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color(red: 227/255, green: 218/255, blue: 208/255))
                    .cornerRadius(15.0)
                }
                
                if (error != "") {
                    Text(error)
                        .foregroundColor(.red).padding()
                }
                Spacer()
            }
            .padding(.horizontal, 32)
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
            .offset(y:  -keyboardResponder.currentHeight*0.9)
        }
    }
}

struct WelcomeText: View {
    var body: some View {
        Text("Welcome!")
            .foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255))
            .font(.custom("Raleway-SemiBold", size: 36))
            .fontWeight(.semibold)
            .padding(.bottom, 20)
    }
}

struct UserImage: View {
    var body: some View {
        Image("AuthViewLogo")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 200, height: 200)
            .padding(.bottom, 75)
    }
}

struct LoginButtonContent: View {
    var body: some View {
        Text("LOGIN")
            .font(.custom("Ubuntu-Light", size: 20))
            .foregroundColor(Color(red: 52/255, green: 83/255, blue: 96/255))
            .padding()
            .frame(width: 220, height: 60)
            .background(Color(red: 227/255, green: 218/255, blue: 208/255))
            .cornerRadius(15.0)
    }
}

struct EmailTextField: View {
    @Binding var email: String
    
    var body: some View {
        return TextField("Email", text: $email)
                .padding()
                .background(lightGreyColor)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .font(.custom("Ubuntu-Light", size: 18))
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
    }
}

struct PasswordSecureField: View {
    @Binding var password: String
    
    var body: some View {
        return SecureField("Password", text: $password)
                .font(.custom("Ubuntu-Light", size: 18))
                .padding()
                .background(lightGreyColor)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
    }
}


struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView().environmentObject(SessionStore())
    }
}
