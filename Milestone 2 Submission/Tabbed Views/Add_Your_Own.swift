//
//  Add_Your_Own.swift
//  Milestone 2 Submission
//
//  Created by Hazel Tan on 23/6/20.
//  Copyright © 2020 Hazel Tan. All rights reserved.
//

import SwiftUI
import FirebaseStorage

struct Add_Your_Own: View {
    var body: some View {
        NavigationView {
            Create_Edit_Delete_View(optionalrecipe: DecodedRecipe(), loaded: false, navigationBarTitle: "New Recipe")
        }
    }
}

struct Add_Your_Own_Previews: PreviewProvider {
    static var previews: some View {
        Add_Your_Own()
    }
}

