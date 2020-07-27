//
//  UUIDRecipe.swift
//  
//
//  Created by Hazel Tan on 6/7/20.
//

import SwiftUI

struct UUIDRecipe: View {
    @ObservedObject var viewModel = RecipeViewModel()
    let recipeUUIDList: [String]
    
    var body: some View {
        List(viewModel.recipes) { recipe in
            BroadAllRecipeView(curr: recipe)
        }.onAppear() {
            UITableView.appearance().separatorStyle = .none
            if self.viewModel.recipes.count == 0 {
                self.viewModel.getSpecificRecipe(uuidList: self.recipeUUIDList)
            }
        }
    }
    
}

struct UUIDRecipe_Previews: PreviewProvider {
    static var previews: some View {
        UUIDRecipe(recipeUUIDList: [String]())
    }
}
