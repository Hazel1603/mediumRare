//
//  Recipe.swift
//  Milestone 2 Submission
//
//  Created by Hazel Tan on 7/12/20.
//  Copyright © 2020 Hazel Tan. All rights reserved.
//

import Foundation

// Data is converted into DecodedRecipe when retrieved from Firebase
struct DecodedRecipe: Identifiable, Comparable {
    var id: String = ""
    var title: String = ""
    var author: String = ""
    var cookTime: String = ""
    var prepTime: String = ""
    var cuisine: String = ""
    var course: String = ""
    var difficulty: String = ""
    var steps: [String] = []
    var cookware: [String] = []
    var servingSize: String = ""
    var notes: [String] = []
    var likes: Int = 0
    var ingList: [IndViewIng] = []
    var sub: [String] = []
    var ingqty: Int = 0
    
    mutating func decreaseLikes() {
        self.likes -= 1
    }
    
    mutating func increaseLikes() {
        self.likes += 1
    }

    static func < (lhs: DecodedRecipe, rhs: DecodedRecipe) -> Bool {
        return lhs.likes > rhs.likes
    }
    
    static func == (lhs: DecodedRecipe, rhs: DecodedRecipe) -> Bool {
        return true
    }
    
    func getSearchResults(ingFilter: [String], cookwareFilter: [String], recipe: DecodedRecipe) -> ingSearchResults {
        let totalIng: Double = Double(recipe.ingList.count)
        var countIng: Double = 0
        
        for m in 0...(recipe.ingList.count-1) {
            let curr = ingList[m]
            if contain(curr: curr.name, list: ingFilter) {
                countIng += 1
            }
        }
        
        // counting cookware
        let totalCookware: Double = Double(recipe.cookware.count)
        var countCookware: Double = 0
        
        for m in 0...(recipe.cookware.count-1) {
            if contain(curr: recipe.cookware[m], list: cookwareFilter) {
                countCookware += 1
            }
        }

        let result = ingSearchResults(recipe: recipe, ingPercentage: Float(countIng/totalIng), ingCount: "\(Int(countIng))/\(Int(totalIng))", cookwarePercentage: Float(countCookware/totalCookware), cookwareCount: "\(Int(countCookware))/\(Int(totalCookware))")
        
        return result
    }
    
    func contain(curr: String, list: [String]) -> Bool {
        var result = false
        for i in list {
            if i.lowercased().contains(curr.lowercased()) || curr.lowercased().contains(i.lowercased()) {
                result = result || true
            }
        }
        return result
    }

}

// Used for storage purposes
struct IndViewIng: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var qty: String
    var sub: String
}

// Used for dealing with ingredients in IngredientsView
struct Ingredient: Identifiable, Hashable {
    var id = String()
    var name: String
    var qty: String
    var sub: String
}


