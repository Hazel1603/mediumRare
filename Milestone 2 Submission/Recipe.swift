//
//  Recipe.swift
//  Milestone 2 Submission
//
//  Created by Hazel Tan on 23/6/20.
//  Copyright © 2020 Hazel Tan. All rights reserved.
//

import Foundation
import FirebaseDatabase

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
    var ingList: [ingredients] = []
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
    
    func IndViewIngList() -> [IndViewIng] {
        var ret: [IndViewIng] = []
        for k in 0...ingqty-1 {
            let curr = IndViewIng(qty: ingList[k].qty, ing: ingList[k].title, sub: sub[k])
            ret.append(curr)
        }
        return ret
    }
}

struct ingredients: Identifiable{
    var id = UUID()
    var title, qty: String
}

struct ingSearchResults: Identifiable, Comparable {
    var id = UUID()
    var recipe: DecodedRecipe
    var ingPercentage: Float
    var ingCount: String
    var cookwarePercentage: Float
    var cookwareCount: String
    
    static func == (lhs: ingSearchResults, rhs: ingSearchResults) -> Bool {
        return lhs.cookwarePercentage > rhs.cookwarePercentage
    }
    
    static func < (lhs: ingSearchResults, rhs: ingSearchResults) -> Bool {
        if lhs.ingPercentage > rhs.ingPercentage {
            return true
        } else if lhs.ingPercentage == rhs.ingPercentage {
            return lhs.cookwarePercentage > rhs.cookwarePercentage
        } else {
            return false
        }
    }
}

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
                let dict = childSnapshot.value as? [String: Any],
                let ing = dict["Ingredients"] as? NSArray,
                let qty = dict["Quantity"] as? NSArray,
                let cookware = dict["cookware"] as? NSArray,
                let title = dict["title"] as? String,
                let k = dict["ingqty"] as? Int
                {
                    print(title)
                    // counting ingredients
                    let totalIng: Double = Double(k)
                    var countIng: Double = 0
                    var ingList = [ingredients]()
                    
                    for curr in 0...(k-1) {
                        let ingTitle = ing[curr] as! String
                        let ingqty = qty[curr] as! String
                        
                        if contain(curr: ingTitle, list: ingFilter) {
                            countIng += 1
                        }
                        
                        let currIng = ingredients(title: ingTitle, qty: ingqty)
                        ingList.append(currIng)
                        
                    }
                    
                    // counting cookware
                    let totalCookware: Double = Double(cookware.count)
                    var countCookware: Double = 0
                    
                    for curr in 0...(cookware.count-1) {
                        if contain(curr: cookware[curr] as! String, list: cookwareFilter) {
                            countCookware += 1
                        }
                    }
                    
                    let curr = recipeConvert(dict: dict)
                    let i = ingSearchResults(recipe: curr, ingPercentage: Float(countIng/totalIng), ingCount: "\(Int(countIng))/\(Int(totalIng))", cookwarePercentage: Float(countCookware/totalCookware), cookwareCount: "\(Int(countCookware))/\(Int(totalCookware))")
                    
                    self.searchResults.append(i)
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

func contain(curr: String, list: [String]) -> Bool {
    var result = false
    for i in list {
        if i.lowercased().contains(curr.lowercased()) || curr.lowercased().contains(i.lowercased()) {
            result = result || true
        }
    }
    return result
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
   
   var ingList = [ingredients]()
   
   for curr in 0...(k!-1) {
       let ingTitle = ing![curr] as! String
       let ingqty = qty![curr] as! String
       let currIng = ingredients(title: ingTitle, qty: ingqty)
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
