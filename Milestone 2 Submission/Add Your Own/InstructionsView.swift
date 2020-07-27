//
//  InstructionsView.swift
//  Milestone 2 Submission
//
//  Created by Ng Jia Xin on 26/6/20.
//  Copyright © 2020 Hazel Tan. All rights reserved.
//

import SwiftUI

struct InstructionsView: View {
    @ObservedObject var instructionList = InstructionList()
    @State var step: String = ""
    @ObservedObject var keyboardResponder = KeyboardResponder()
    
    func addInstruction() {
        instructionList.instructions.append(Instruction(id: String(instructionList.instructions.count), instr: step))
        self.step = ""
    }
    
    var body: some View {
        VStack {
            ForEach(self.instructionList.instructions, id:\.id) { instr in
                HStack {
                    Text("Step " + String((Int(instr.id)!+1)) + ": ")
                        .font(.custom("Ubuntu-Light", size: 18))
                    Text(instr.instr).multilineTextAlignment(.leading)
                        .font(.custom("Ubuntu-Light", size: 18))
                    Spacer()
                    Image(systemName: "multiply.circle.fill")
                        .onTapGesture {
                            print(instr.id)
                            self.instructionList.removeAtIndex(index: Int(instr.id)!)
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
        }.navigationBarTitle("Instructions")
    }
}

struct Instruction: Identifiable {
    var id: String
    var instr: String
}

class InstructionList: ObservableObject {
    @Published var instructions = [Instruction]()
    
    func edit(instr: [String]) {
        if instructions.count >= instr.count {
            return
        } else if instr.count >= 1 {
            for m in 0...instr.count-1 {
                instructions.append(Instruction(id: String(m), instr: instr[m]))
            }
        }
    }
    
    func instr() -> [String] {
        var result = [String]()
        for instruc in instructions {
            result.append(instruc.instr)
        }
        return result
    }
    
    func reset() {
        instructions = [Instruction]()
    }
    
    func removeAtIndex(index: Int) {
        var ret = instructions
        if instructions.count == 1 && index == 0 {
            instructions = []
        } else if index == instructions.count - 1 {
            instructions.removeLast()
        } else {
            ret.remove(at: index)
            for k in index..<instructions.count-1 {
                ret[k] = Instruction(id: String(k), instr: ret[k].instr)
            }
            instructions = ret
        }
    }
}

struct InstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsView()
    }
}

struct NotesView: View {
    @ObservedObject var notesList: NotesList = NotesList()
    @State var note: String = ""
    @ObservedObject var keyboardResponder = KeyboardResponder()
    
    func addNote(newNote: Instruction) {
        notesList.notes.append(newNote)
        self.note = ""
    }
    var body: some View {
        VStack {
            ForEach(self.notesList.notes, id: \.id) { curr in
                HStack {
                    Text(String((Int(curr.id)!+1)) + ". \(curr.instr)")
                        .font(.custom("Ubuntu-Light", size: 18))
                    Spacer()
                    Image(systemName: "multiply.circle.fill")
                        .onTapGesture {
                            self.notesList.removeAtIndex(index: Int(curr.id)!)
                        }
                }.padding(.horizontal).padding(.bottom, 8)
            }
            Spacer()
            HStack {
                MultilineTextField("notes...", text: $note)
                    .font(.custom("Ubuntu-Light", size: 18))
                    .foregroundColor(Color(red: 52/255, green: 73/255, blue: 96/255))
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray))
                    .padding()
                    
                Button(action: {
                    if self.note != "" {
                        self.addNote(newNote: Instruction(id: String(self.notesList.notes.count), instr: self.note))
                    }
                    self.hideKeyboard()
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 32, weight: .regular))
                        .foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255))
                        .offset(x: -10)
                }
            }.offset(y: -keyboardResponder.currentHeight*0.9)
        }
        .navigationBarTitle("Chef's notes")
    }
}

class NotesList: ObservableObject {
    @Published var notes = [Instruction]()
    
    func edit(note: [String]) {
        if notes.count >= note.count {
            return
        } else if note.count >= 1 && note[0] != "" {
            for m in 0...note.count-1 {
                notes.append(Instruction(id: String(m), instr: note[m]))
            }
        }
    }
    
    func removeAtIndex(index: Int) {
        var ret = notes
        if notes.count == 1 && index == 0 {
            notes = []
        } else if index == notes.count - 1 {
            notes.removeLast()
        } else {
            ret.remove(at: index)
            for k in index..<notes.count-1 {
                ret[k] = Instruction(id: String(k), instr: ret[k].instr)
            }
            notes = ret
        }
    }
    
    func arrayIt() -> [String] {
        var result: [String] = []
        for n in notes {
            result.append(n.instr)
        }
        print(result.isEmpty)
        return result
    }
    
    func reset() {
        notes = [Instruction]()
    }
}
