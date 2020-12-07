//
//  FirebaseImageView.swift
//  Milestone 2 Submission
//
//  Created by Ng Jia Xin on 20/7/20.
//  Copyright © 2020 Hazel Tan. All rights reserved.
//

import SwiftUI
import Combine
import FirebaseStorage

struct FirebaseImageView: View {
    @ObservedObject var dataLoader:DataLoader
    @State var image:UIImage = UIImage()

    init(imageURL: String) {
        dataLoader = DataLoader(urlString: imageURL)
    }
    func imageFromData(_ data:Data) -> UIImage {
        UIImage(data: data) ?? UIImage()
    }

    var body: some View {
        VStack {
            Image(uiImage: dataLoader.dataIsValid ? imageFromData(dataLoader.data!) : UIImage())
                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width:100, height:100)
        }
    }
}

class DataLoader: ObservableObject {
    @Published var dataIsValid = false
    var data:Data?

    init(urlString:String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.dataIsValid = true
                self.data = data
            }
        }
        task.resume()
    }
}
