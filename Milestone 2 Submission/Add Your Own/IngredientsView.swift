//
//  IngredientsView.swift
//  Milestone 2 Submission
//
//  Created by Ng Jia Xin on 24/6/20.
//  Copyright © 2020 Hazel Tan. All rights reserved.
//

import SwiftUI

struct IngredientsView: View {
    @ObservedObject var ingredientList = IngredientList()
    @State var newName: String = ""
    @State var newQty: String = ""
    @State var sub: String = "nil"
    @State private var selection: Set<Ingredient> = []
    @ObservedObject var keyboardResponder = KeyboardResponder()
    
    func addIngredient() {
        ingredientList.addIngredient(newIng: Ingredient(id: String(ingredientList.ingredients.count), name: newName, qty: newQty, sub: sub))
        self.newName = ""
        self.newQty = ""
        self.sub = "nil"
    }
    
    var body: some View {
        VStack {
            ForEach(self.ingredientList.ingredients, id: \.id) { item in
                HStack {
                    IngRowView(ingredient: item, isExpanded: self.selection.contains(item))
                    Spacer()
                    Button(action: {
                        self.ingredientList.removeAtIndex(index: Int(item.id)!)
                    }) {
                        Image(systemName: "multiply.circle.fill")
                    }.buttonStyle(PlainButtonStyle())
                }.padding(.horizontal).padding(.bottom, 8)
            }
            Spacer()
            Text("Add new ingredient")
                .font(.custom("Raleway-SemiBold", size: 14))
            ZStack(alignment: .trailing) {
                VStack{
                    HStack {
                        TextField("New ingredient", text: self.$newName)
                            .font(.custom("Ubuntu-Light", size: 18))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                        Spacer()
                        TextField("Quantity", text: self.$newQty)
                            .font(.custom("Ubuntu-Light", size: 18))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                    }
                    HStack {
                        Text("Any substitutes?")
                            .font(.custom("Raleway-SemiBold", size: 14))
                        TextField("Substitute here...", text: self.$sub)
                            .font(.custom("Ubuntu-Light", size: 18))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding()
                
                Button(action: {
                    if self.newName != "" && self.newQty != "" {
                        self.addIngredient()
                    }
                    self.hideKeyboard()
                }
                    , label: {
                    Image(systemName: "cart.fill.badge.plus")
                        .foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255))
                        .font(.system(size: 28, weight: .regular))
                        .padding()
                }).offset(y: -75)
            }
            .offset(y: -keyboardResponder.currentHeight*0.9)
        }.navigationBarTitle("Ingredients").foregroundColor(Color(red: 52/255, green: 73/255, blue: 96/255))
            //.foregroundColor(Color(red: 227/255, green: 218/255, blue: 208/255))
    }
}

class IngredientList: ObservableObject {
    @Published var ingredients = [Ingredient]()
    
    func edit(decodedIng: [ingredients], subs: [String]) {
        if ingredients.count >= decodedIng.count {
            return
        } else if decodedIng.count >= 1 {
            for m in 0...decodedIng.count-1 {
                ingredients.append(Ingredient(id: String(m), name: decodedIng[m].title, qty: decodedIng[m].qty, sub: subs[m]))
            }
        }
    }
    
    func names() -> [String] {
        var result = [String]()
        for ingredient in ingredients {
            result.append(ingredient.name)
        }
        return result
    }
    
    func subArray() -> [String] {
        var results = [String]()
        for ing in ingredients {
            results.append(ing.sub)
        }
        //print(results)
        return results
    }
    
    func quantified() -> [String]{
        var result = [String]()
        for ingredient in ingredients {
            result.append(ingredient.qty)
        }
        return result
    }
    
    func reset() {
        ingredients = [Ingredient]()
    }
    
    func addIngredient(newIng: Ingredient) {
        var curr = ingredients
        curr.append(newIng)
        ingredients = curr
    }
    
    func removeAtIndex(index: Int) {
        var ret = ingredients
        if ingredients.count == 1 && index == 0 {
            ingredients = []
        } else if index == ingredients.count - 1 {
            ingredients.removeLast()
        } else {
            ret.remove(at: index)
            for k in index..<ingredients.count-1 {
                ret[k] = Ingredient(id: String(k), name: ret[k].name, qty: ret[k].qty, sub: ret[k].sub)
            }
            ingredients = ret
        }
    }
    
}

struct IngRowView: View {
    let ingredient: Ingredient
    @State var isExpanded: Bool
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text(self.ingredient.name)
                        .font(.custom("Ubuntu-Light", size: 18))
                    Spacer()
                    Text(ingredient.qty)
                        .font(.custom("Ubuntu-Light", size: 18)).bold()
                        .background(Color(red: 227/255, green: 218/255, blue: 208/255))
                        .cornerRadius(4.0)
                        .opacity(0.3)
                }.contentShape(Rectangle())
                if self.isExpanded {
                    VStack(alignment: .leading) {
                        Text("Substitute: \(self.ingredient.sub)")
                            .font(.custom("Ubuntu-Light", size: 18))
                            .foregroundColor(Color.secondary)
                    }
                }
            }.onTapGesture {
                self.isExpanded.toggle()
            }
        }
    }
}

struct Ingredient: Identifiable, Hashable {
    var id = String()
    var name: String
    var qty: String
    var sub: String = "nil"
}

struct IngredientsView_Previews: PreviewProvider {
    static var previews: some View {
        IngredientsView()
    }
}
