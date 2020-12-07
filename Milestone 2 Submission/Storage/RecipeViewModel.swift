//
//  Recipe.swift
//  Milestone 2 Submission
//
//  Created by Hazel Tan on 23/6/20.
//  Copyright © 2020 Hazel Tan. All rights reserved.
//

import Foundation
import FirebaseDatabase

class RecipeViewModel: ObservableObject {
    @Published var recipes = [DecodedRecipe]()
    @Published var searchResults = [ingSearchResults]()
    
    private var ref = Database.database().reference()
    
    func reset() {
        self.recipes = [DecodedRecipe]()
        self.searchResults = [ingSearchResults]()
    }
    
    func addRecipe(recipe: EncodedRecipe) {
        ref = ref.child("recipes").child(recipe.id)
//        print(ref.key)
//        print(recipe.id)
        ref.setValue(recipe.makeItAnArray(), withCompletionBlock: {error, ref in
            if error == nil {
                print("Success")
            } else {
                print(error as Any)
            }
        })
    }
    
    func removeRecipe(uuid: String) {
        ref.child("recipes").child(uuid).removeValue()
    }

    // filters based on ingredient list and cookware list
    func filteredSearch(ingFilter: [String], cookwareFilter: [String]) {
        ref = ref.child("recipes")
        print("called ingredient search")
        ref.observeSingleEvent(of:.value, with: { snapshot in
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                let dict = childSnapshot.value as? [String: Any]
                {
                    // converts data into a DecodedRecipe
                    let curr = recipeConvert(dict: dict)
                    let searchResult = curr.getSearchResults(ingFilter: ingFilter, cookwareFilter: cookwareFilter, recipe: curr)
                    self.searchResults.append(searchResult)
                    self.searchResults.sort()
                }
            }
        })
    }
    
    // gets recipe based on UUID in Firebase
    func getSpecificRecipe(uuidList: [String]) {
        for m in 0...uuidList.count-1 {
            ref.child("recipes").child(uuidList[m]).observe(.value, with: { (snapshot) in
                if let dict = snapshot.value as? [String: Any]{
                        let curr = recipeConvert(dict: dict)
                        print(curr.title)
                        self.recipes.append(curr)
                    }
            })
        }
    }
    
    // takes in fieldname and filter and returns a list of recipes tha match the restrictions
    func homepageFilter(field: String, filterStr: String, filterNum: Int) {
        ref = ref.child("recipes")
        ref.observe(.value, with: { snapshot in
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                let dict = childSnapshot.value as? [String: Any]
                {
                    var pivot = false
                    if filterNum == 0 {
                        let currField = dict[field] as? String
                        pivot = currField == filterStr
                    } else {
                        let currField = dict[field] as? String
                        pivot = Int(currField!) ?? 0 <= filterNum
                    }
                    
                    if pivot {
                        let curr = recipeConvert(dict: dict)
                        self.recipes.append(curr)
                    }
                }
            }
        })
    }
    
    func orderByLikes() {
//        self.recipes = [DecodedRecipe]()
        ref = ref.child("recipes")
        
        ref.observeSingleEvent(of: .value, with: {snapshot in
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                let dict = childSnapshot.value as? [String: Any]{
                    let curr = recipeConvert(dict: dict)
                    var replaced = false
                    if self.recipes.count == 0 {
                        print(curr.title)
                        self.recipes.append(curr)
                        self.recipes.sort()
                    } else {
                        print(curr.title)
                        for m in 0..<self.recipes.count {
                            let loopRecipe = self.recipes[m]
                            if curr.id == loopRecipe.id {
                                self.recipes[m] = curr
                                replaced = true
                            }
                        }
                        if !replaced {
                            self.recipes.append(curr)
                            self.recipes.sort()
                        }
                    }
                }
            }
        })
    }
    
    // sorts results
    func sortSearchResults(ingFilter: [String], cookwareFilter: [String]) {
        filteredSearch(ingFilter: ingFilter, cookwareFilter: cookwareFilter)
        print("sorted")
        searchResults = self.searchResults.sorted()
//        return self.searchResults
    }
    
    // getter
    func getSearchResults() -> [ingSearchResults] {
        print("called getSearchResults")
        for k in 0..<searchResults.count {
            print(searchResults[k].recipe.title)
        }
        
        return self.searchResults
    }
    
    // modifies likes of recipe
    func updateLikes(uuid: String, newValue: Int) {
        ref.child("recipes").child(uuid).updateChildValues(["likes": newValue], withCompletionBlock: {error, ref in
            if error == nil {
                print("Success adding like")
            } else {
                print(error as Any)
            }
        })
    }
}

func recipeConvert(dict: [String: Any]) -> DecodedRecipe {
    let id = dict["id"] as? String
    let ing = dict["Ingredients"] as? NSArray
    let qty = dict["Quantity"] as? NSArray
    let cookware = dict["cookware"] as? NSArray
    let steps = dict["steps"] as? NSArray
    let title = dict["title"] as? String
    let author = dict["author"] as? String
    let cookTime = dict["cookTime"] as? String
    let prepTime = dict["prepTime"] as? String
    let difficulty = dict["difficulty"] as? String
    let course = dict["course"] as? String
    let cuisine = dict["cuisine"] as? String
    let servingSize = dict["servingSize"] as? String
    let k = dict["ingqty"] as? Int
    let likes = dict["likes"] as? Int
    let notes = dict["notes"] as? NSArray
    let sub = dict["substitute"] as? NSArray
   
    var ingList = [IndViewIng]()
   
   for curr in 0...(k!-1) {
        let ingTitle = ing![curr] as! String
        let ingqty = qty![curr] as! String
        let sub = sub![curr] as! String
        let currIng = IndViewIng(name: ingTitle, qty: ingqty, sub: sub)
       ingList.append(currIng)
   }
    
   let curr = DecodedRecipe(
       id: id!,
       title: title ?? "Unknown",
       author: author ?? "Samaritan",
       cookTime: cookTime ?? "Unstated",
       prepTime: prepTime ?? "Unstated",
       cuisine: cuisine ?? "Global",
       course: course ?? "Universal",
       difficulty: difficulty ?? "Average",
       steps: steps as! [String],
       cookware: cookware as! [String],
       servingSize: servingSize ?? "Unclear",
       notes: notes as! [String],
       likes: likes ?? 0,
       ingList: ingList,
       sub: sub as! [String],
       ingqty: k ?? 0)
    
    return curr
}
