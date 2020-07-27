//
//  ContentView.swift
//  Milestone 2 Submission
//
//  Created by Hazel Tan on 23/6/20.
//  Copyright © 2020 Hazel Tan. All rights reserved.
//

import SwiftUI

struct TabbedView: View {
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var session: SessionStore
    @ObservedObject var viewModel = RecipeViewModel()
    
    var body: some View {
        TabView{
            Homepage()
//            ingListView()
                .tabItem {
                    Image(systemName: "checkmark.seal")
                    Text("Home Page")
            }
            SearchFilter()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
            }
            Add_Your_Own()
               .tabItem {
                   Image(systemName: "plus")
                   Text("Add Your Own")
           }
            Bookmarks()
                .tabItem {
                    Image(systemName:"bookmark.fill")
                    Text("Bookmarks")
            }
            Settings()
                .tabItem {
                    Image(systemName:"gear")
                    Text("Settings")
            }
        }
        .onAppear(perform: {
            if self.userProfile.username == "" {
                    self.userProfile.setIdToken(idToken: self.session.idToken)
                    self.userProfile.getProfile()
                    print(self.userProfile.username + " updateProfile in settings")
            }
        })
    }
}

struct TabbedView_Previews: PreviewProvider {
    static var previews: some View {
        TabbedView()
    }
}
