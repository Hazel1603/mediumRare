//
//  Instruction_Note_View.swift
//  Milestone 2 Submission
//
//  Created by Hazel Tan on 7/12/20.
//  Copyright © 2020 Hazel Tan. All rights reserved.
//

import SwiftUI

struct Item: Identifiable {
    var id: String
    var details: String
}

struct Instruction_Note_View: View {
    @ObservedObject var itemList = ItemList()
    @State var step: String = ""
    @ObservedObject var keyboardResponder = KeyboardResponder()
    
    func addInstruction() {
        itemList.items.append(Item(id: String(itemList.items.count), details: step))
        self.step = ""
    }
    
    var body: some View {
        VStack {
            ForEach(self.itemList.items, id:\.id) { item in
                HStack {
                    Text("Step " + String((Int(item.id)!+1)) + ": ")
                        .font(.custom("Ubuntu-Light", size: 18))
                    Text(item.details).multilineTextAlignment(.leading)
                        .font(.custom("Ubuntu-Light", size: 18))
                    Spacer()
                    Image(systemName: "multiply.circle.fill")
                        .onTapGesture {
                            print(item.id)
                            self.itemList.removeAtIndex(index: Int(item.id)!)
                        }
                }.foregroundColor(Color(red: 52/255, green: 73/255, blue: 96/255))
                    .padding(.horizontal).padding(.bottom, 8)
            }
            Spacer()
                HStack {
                    MultilineTextField("What to do next?", text: self.$step)
                        .font(.custom("Ubuntu-Light", size: 18))
                        .foregroundColor(Color(red: 52/255, green: 73/255, blue: 96/255))
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray))
                        .padding()
                        
                    Button(action: {
                        if self.step != "" {
                            self.addInstruction()
                            self.step = ""
                        }
                        self.hideKeyboard()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255))
                            .frame(width: 30, height: 30)
                            .padding()
                            .offset(y: 0)
                    }
                }.offset(y: -keyboardResponder.currentHeight*0.9)
        }.navigationBarTitle("items")
    }
}

class ItemList: ObservableObject {
    @Published var items = [Item]()
    
    func edit(lst: [String]) {
        if items.count >= lst.count {
            return
        } else if lst.count >= 1 {
            for m in 0...lst.count-1 {
                items.append(Item(id: String(m), details: lst[m]))
            }
        }
    }
    
    func instr() -> [String] {
        var result = [String]()
        for i in items {
            result.append(i.details)
        }
        return result
    }
    
    func reset() {
        items = [Item]()
    }
    
    func removeAtIndex(index: Int) {
        var ret = items
        if items.count == 1 && index == 0 {
            items = []
        } else if index == items.count - 1 {
            items.removeLast()
        } else {
            ret.remove(at: index)
            for k in index..<items.count-1 {
                ret[k] = Item(id: String(k), details: ret[k].details)
            }
            items = ret
        }
    }
    
    func arrayIt() -> [String] {
        var result: [String] = []
        for n in items {
            result.append(n.details)
        }
        return result
    }
}

struct Instruction_Note_View_Previews: PreviewProvider {
    static var previews: some View {
        Instruction_Note_View()
    }
}
