//
//  SessionStore.swift
//  Trial
//
//  Created by Ng Jia Xin on 5/7/20.
//  Copyright © 2020 Ng Jia Xin. All rights reserved.
//

import SwiftUI
import Firebase
import Combine
import FirebaseStorage

class SessionStore : ObservableObject {
    var didChange = PassthroughSubject<SessionStore, Never>()
    @Published var session: User? { didSet { self.didChange.send(self) }}
    @Published var idToken = ""
    let storage = Storage.storage().reference().child("profileIcons")
    
    var handle: AuthStateDidChangeListenerHandle?

    func listen () {
        // monitor authentication changes using firebase
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                // if we have a user, create a new user model
                print("Got user: \(user)")
                self.session = User(
                    uid: user.uid,
                    displayName: user.displayName,
                    email: user.email
                )
                self.idToken = user.uid
                print("idtoken is \(self.idToken) at listen()")
            } else {
                // if we don't have a user, set our session to nil
                self.session = nil
            }
        }
    }

    // additional methods (sign up, sign in) will go here
    func signUp(
        email: String,
        password: String,
        displayName: String,
        handler: @escaping AuthDataResultCallback
        ) {
        Auth.auth().createUser(withEmail: email, password: password, completion: handler)
    }

    func signIn(
        email: String,
        password: String,
        handler: @escaping AuthDataResultCallback
        ) {
        Auth.auth().signIn(withEmail: email, password: password, completion: handler)
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.session = nil
        } catch {
            print("Error signing out")
        }
    }
    
    func unbind () {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func changeEmail(email: String) {
        Auth.auth().currentUser?.updateEmail(to: email) { (error) in
            if error == nil {
                print("Email changed!")
            } else {
                print(error as Any)
            }
        }
    }
    
    func changePassword(password: String) {
        Auth.auth().currentUser?.updatePassword(to: password) { (error) in
            if error == nil {
                print("Password changed!")
            } else {
                print(error as Any)
            }
        }
    }
    
    func getProfilePicture() -> String {
        var imageURL: String = ""
        let storage = Storage.storage().reference(withPath: "\(self.idToken)")
        storage.downloadURL { (url, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                return
            }
            imageURL = "\(url!)"
        }
        return imageURL
    }
}

class User {
    var uid: String
    var email: String?
    var displayName: String?

    init(uid: String, displayName: String?, email: String?) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
    }

}


