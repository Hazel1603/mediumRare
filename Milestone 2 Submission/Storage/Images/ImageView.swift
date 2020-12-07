//
//  ImageView.swift
//  Milestone 2 Submission
//
//  Created by Ng Jia Xin on 20/7/20.
//  Copyright © 2020 Hazel Tan. All rights reserved.
//

import SwiftUI
import FirebaseStorage
import Combine

var FILE_NAME = "tests/-MAVUmUhe5CIOAlbxz8m.jpg"

struct ImageView: View {
    @State var shown = false
    @State var imageURL = ""
    
    var body: some View {
        VStack {
            FirebaseImageView(imageURL: imageURL).frame(width: 300, height: 300)
            Button(action: loadImageFromFirebase) {
                Text("Load")
            }
        }
    }
    
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
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView()
    }
}
