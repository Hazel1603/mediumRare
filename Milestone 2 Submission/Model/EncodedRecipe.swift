//
//  EncodedRecipe.swift
//  Milestone 2 Submission
//
//  Created by Hazel Tan on 7/12/20.
//  Copyright © 2020 Hazel Tan. All rights reserved.
//

import Foundation

// Data is converted into Encoded Recipe when trying to store into Firebase
struct EncodedRecipe: Identifiable {
    var id: String
    var title: String
    var author: String
    var cookTime: String
    var prepTime: String
    var cuisine: String
    var course: String
    var difficulty: String
    var steps: [String]
    var cookware: [String]
    var servingSize: String
    var notes: [String]
    var Ingredients: [String]
    var ingqty: Int
    var likes: Int
    var Quantity: [String]
    var sub: [String]
    
    func makeItAnArray() -> [String: Any] {
        let item = [
            "id": self.id,
            "title": self.title,
            "author": self.author,
            "cookTime": self.cookTime,
            "prepTime": self.prepTime,
            "cuisine": self.cuisine,
            "course": self.course,
            "difficulty": self.difficulty,
            "cookware": self.cookware,
            "servingSize": self.servingSize,
            "notes": self.notes,
            "ingqty": self.Ingredients.count,
            "Ingredients": self.Ingredients,
            "Quantity" : self.Quantity,
            "steps": self.steps,
            "likes": self.likes,
            "substitute": self.sub
            ] as [String : Any]
        
        return item
    }
    
    static func arrayToString(array: [String]) -> String {
        if array.isEmpty {
            return ""
        } else if array.count <= 1 {
            return array[0]
        } else {
            var ret = ""
            for m in 0...array.count-2{
                ret += array[m]
            }
            ret += array[array.count-1]
            return ret
        }
    }
}
