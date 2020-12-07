//
//  SearchResults.swift
//  Milestone 2 Submission
//
//  Created by Hazel Tan on 7/12/20.
//  Copyright © 2020 Hazel Tan. All rights reserved.
//

import Foundation

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

