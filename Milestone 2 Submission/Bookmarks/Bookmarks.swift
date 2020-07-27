//
//  Bookmarks.swift
//  Milestone 2 Submission
//
//  Created by Hazel Tan on 6/7/20.
//  Copyright © 2020 Hazel Tan. All rights reserved.
//

import SwiftUI

struct Bookmarks: View {
    @EnvironmentObject var userProfile: UserProfile
//    @State var present = false
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [
        .font : UIFont(name:"Raleway-SemiBold", size: 40)!]
    }
    
    var body: some View {
        NavigationView {
            if userProfile.bookmarks.count <= 1 {
                Text("No bookmarks")
            } else {
                UUIDRecipe(recipeUUIDList: userProfile.bookmarks)
                .navigationBarTitle("Bookmarks")
            }
        }
    }
}

struct Bookmarks_Previews: PreviewProvider {
    static var previews: some View {
        Bookmarks()
    }
}
