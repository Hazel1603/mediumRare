//
//  ContentView.swift
//  Trial
//
//  Created by Ng Jia Xin on 19/6/20.
//  Copyright © 2020 Ng Jia Xin. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var userProfile: UserProfile
    @State var updated: Bool = false
    
    func getUser() {
        session.listen()
    }

    
    var body: some View {
        Group {
            if (session.session != nil) {
                TabbedView()
                //if updateProfile() {
//                    UserProfileView()
                //}
                
            } else {
                AuthView()
            }
            
        }.onAppear(perform: getUser)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(SessionStore())
    }
}
