//
//  Trial.swift
//  Milestone 2 Submission
//
//  Created by Hazel Tan on 23/7/20.
//  Copyright © 2020 Hazel Tan. All rights reserved.
//

import SwiftUI
import FirebaseStorage

struct Trial: View {
    @EnvironmentObject var session: SessionStore
    @EnvironmentObject var userProfile: UserProfile
    @State var optionalrecipe: DecodedRecipe
    @State var loaded: Bool
    var navigationBarTitle: String
    @Environment(\.presentationMode) var presentationMode
    
    
    @State var title = ""
    @State var cuisine = ""
    @State var cookTime = ""
    @State var prepTime = ""
    @State var cookwareString = ""
    @State var diffIndex = 0
    @State var servingSize = 0
    @State var timeInt = 60.0
    @State var showingAlert = false
    @State var notes = ""
    @State var showingDeleteAlert = false
    
    let courses: [course] = [
        course(title: "Appetizer", index: 0),
        course(title: "Main", index: 1),
        course(title: "Dessert", index: 2),
        course(title: "Salad", index: 3),
        course(title: "Soup", index: 4)
    ]
    
    let difficulty = ["Easy", "Medium", "Hard", "Challenging"]
    @ObservedObject var ingredientList = IngredientList()
    @ObservedObject var instructionList = InstructionList()
    @ObservedObject var notesList = NotesList()
    @ObservedObject var currentSelection = cuisineChoice()
    
    @State var showingImagePicker = false
    @State var inputImage: UIImage?
    @State var image: Image?
    @State var imageURL: String = ""
    let storage = Storage.storage().reference().child("tests")
    
    func loadImageFromFirebase(fileName: String) {
        let storage = Storage.storage().reference(withPath: fileName)
        storage.downloadURL { (url, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                return
            }
            self.imageURL = "\(url!)"
        }
    }
    
    func load(recipe: DecodedRecipe) {
        loadImageFromFirebase(fileName: "tests/\(recipe.id)")
        self.title = recipe.title
        self.cuisine = recipe.cuisine
        self.cookTime = recipe.cookTime
        self.prepTime = recipe.prepTime
        self.cookwareString = arrayToString(array: recipe.cookware)
        self.servingSize = Int(recipe.servingSize) ?? 0
        self.currentSelection.edit(currChoice: recipe.course, array: courses)
        self.diffIndex = difficulty.firstIndex(of: recipe.difficulty) ?? 0
        self.ingredientList.edit(decodedIng: recipe.ingList, subs: recipe.sub)
        self.instructionList.edit(instr: recipe.steps)
        self.notesList.edit(note: recipe.notes)
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    func uploadImageToFireBase(image: UIImage, fileName: String) {
        // Create the file metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Upload the file to the path FILE_NAME
        storage.child(fileName).putData(image.jpegData(compressionQuality: 0.42)!, metadata: metadata) { (metadata, error) in
            guard let metadata = metadata else {
              // Uh-oh, an error occurred!
              print((error?.localizedDescription)!)
              return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            
            print("Upload size is \(size)")
            print("Upload success")
        }
    }
    
    func reset() {
        self.title = ""
        self.cuisine = ""
        self.cookTime = ""
        self.prepTime = ""
        self.cookwareString = ""
        self.diffIndex = 0
        self.servingSize = 0
        self.notes = ""
        self.currentSelection.reset()
        self.ingredientList.reset()
        self.instructionList.reset()
        self.notesList.reset()
        self.image = nil
    }
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
            VStack {
                //Image
                ZStack {
                    if imageURL == "" && image == nil {
                        Rectangle()
                            .frame(width: 350, height: 300)
                            .foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255))
                        Text("Tap to add photo")
                            .font(.custom("Ubuntu-Light", size: 18))
                    } else if image != nil {
                        image?
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 350, height: 300)
                            .clipShape(Rectangle())
                    } else {
                        FirebaseImageView(imageURL: imageURL)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 350, height: 350)
                        .clipShape(Rectangle())
                    }
                }.onTapGesture {
                    self.showingImagePicker = true
                }
                //Basic Info
                Group {
                    HStack {
                        Text("Recipe Title")
                            .font(.custom("Ubuntu-Light", size: 18))
                            .foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255))
                        Spacer()
                        TextField("Carbonara", text: $title)
                            .font(.custom("Ubuntu-Light", size: 18))
                    }.padding()
                    HStack {
                        Text("Cuisine")
                            .font(.custom("Ubuntu-Light", size: 18))
                            .foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255))
                        Spacer()
                        Spacer()
                        TextField("Italian", text: $cuisine)
                            .font(.custom("Ubuntu-Light", size: 18))
                    }.padding()
                    HStack(alignment: .center) {
                        Text("Cooking Time")
                            .foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255))
                            .font(.custom("Ubuntu-Light", size: 18))
                        Spacer()
                        TextField("In minutes", text: $cookTime)
                            .font(.custom("Ubuntu-Light", size: 18))
                            .keyboardType(.numberPad)
                    }.padding()
                    HStack {
                        Text("Prep Time")
                            .font(.custom("Ubuntu-Light", size: 18))
                            .foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255))
                        Spacer()
                        TextField("In minutes", text: $prepTime)
                            .font(.custom("Ubuntu-Light", size: 18))
                            .keyboardType(.numberPad)
                    }.padding()
                    
                    HStack {
                        Text("Cookware")
                            .font(.custom("Ubuntu-Light", size: 18))
                            .foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255))
                        Spacer()
                        TextField("Oven, Crockpot, Dehydrator", text: $cookwareString)
                            .font(.custom("Ubuntu-Light", size: 18))
                    }.padding()
                }
                // Serving size
                StepperView(serving: $servingSize)
                
                // Course Selection
                 ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(0..<courses.count) {
                            courseView(box: self.courses[$0], currentSelection: self.currentSelection, selected: false)
                        }
                    }
                }
//                    Button(action: {
//                        print(self.courses[self.courseIndex])
//                    }) { Text("no")}
                
                //Difficulty Selection
                Picker(selection: $diffIndex, label: Text("Difficulty")) {
                    ForEach(0..<difficulty.count) {
                        Text(self.difficulty[$0])
                            .padding()
                            .font(.custom("Ubuntu-Light", size: 18))
                    }
                }.pickerStyle(SegmentedPickerStyle()).cornerRadius(5.0)
                // Chef Notes
                NavigationLink(destination: NotesView(notesList: notesList)) {
                    Text("Chef's notes")
                        .foregroundColor(Color(red: 52/255, green: 83/255, blue: 96/255))
                        .font(.custom("Raleway-SemiBold", size: 18))
                        .padding()
                }
                //ingredient & Instructions
                HStack {
                    NavigationLink(destination: IngredientsView(ingredientList: ingredientList)) {
                        Text("Add Ingredients")
                            .foregroundColor(Color(red: 52/255, green: 83/255, blue: 96/255))
                            .font(.custom("Raleway-SemiBold", size: 18))
                            .padding()
                    }
                    Spacer()
                    NavigationLink(destination: InstructionsView(instructionList: instructionList)) {
                        Text("Instructions")
                            .foregroundColor(Color(red: 52/255, green: 83/255, blue: 96/255))
                            .font(.custom("Raleway-SemiBold", size: 18))
                            .padding()
                    }
                }
                
                if self.navigationBarTitle == "Edit" {
                    Button (action: {
                        self.showingDeleteAlert.toggle()
                    }) {
                        Text("Delete").foregroundColor(Color.red)
                    }.buttonStyle(PlainButtonStyle())
                    .alert(isPresented: $showingDeleteAlert){
                        Alert(title: Text("Do you want to delete?"), message: Text("You can't undo this action"),
                              primaryButton:.destructive(Text("Delete")) {
                                RecipeViewModel().removeRecipe(uuid: self.optionalrecipe.id)
                                self.presentationMode.wrappedValue.dismiss()
                            }, secondaryButton: .cancel())
                    }
                }
            }
        }
        }.navigationBarTitle(self.navigationBarTitle)
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        }
    .onAppear(perform: {
        print(self.optionalrecipe.title)
        if !self.loaded && self.optionalrecipe.title != "" {
            self.load(recipe: self.optionalrecipe)
        }
        self.loaded.toggle()
    })
        .navigationBarItems(trailing: Button(action: {
            // create obj
            self.showingAlert = true
            print("no")
            print(self.optionalrecipe.id)
        }) {
            Text("Save")
        })
        .alert(isPresented:$showingAlert) {
            Alert(title: Text("Are you sure?"), message: Text("You can't undo this action"), primaryButton: .destructive(Text("Yes")) {
                //print("Adding your recipe ^_^")
                let ingredients = self.ingredientList.names()
                let quantities = self.ingredientList.quantified()
                let notee = self.notesList.arrayIt().isEmpty ? [""] : self.notesList.arrayIt()
                let cookware = self.cookwareString.components(separatedBy: ", ")

                let curr: EncodedRecipe = EncodedRecipe(
                    id: self.optionalrecipe.id == "" ? UUID().uuidString : self.optionalrecipe.id,
                    title: self.title,
                    author: self.userProfile.username,
                    cookTime: self.cookTime,
                    prepTime: self.prepTime,
                    cuisine: self.cuisine,
                    course: self.currentSelection.title,
                    difficulty: self.difficulty[self.diffIndex],
                    steps: self.instructionList.instr(),
                    cookware: cookware,
                    servingSize: String(self.servingSize),
                    notes: notee,
                    Ingredients: ingredients,
                    ingqty: ingredients.count,
                    likes: 0,
                    Quantity: quantities,
                    sub: self.ingredientList.subArray()
                )

                RecipeViewModel().addRecipe(recipe: curr)
                self.userProfile.addYourRecipes(recipe: curr.id)
                if self.inputImage != nil {
                    let fileName = curr.id
                    self.uploadImageToFireBase(image: self.inputImage!, fileName: fileName)
                }

                self.reset()
                self.presentationMode.wrappedValue.dismiss()
                }, secondaryButton: .cancel())
        }
        
    }
}

struct course {
    var title: String
    var index: Int
}

struct courseView: View {
    var box: course
    @ObservedObject var currentSelection: cuisineChoice
    @State var selected: Bool
    
    var body: some View {
        Button(action: {
            if self.selected { //already selected
                self.selected = false
                self.currentSelection.chosen = -1
                self.currentSelection.title = ""
                print(self.currentSelection.chosen)
            } else { // not selected
                self.currentSelection.chosen = self.box.index
                self.currentSelection.title = self.box.title
                self.selected = true
                print(self.currentSelection.chosen)
            }
        }) {
            if currentSelection.chosen != box.index {
                Text(box.title)
                    .font(.custom("Ubuntu-Light", size: 18))
                    .foregroundColor(Color(red: 52/255, green: 83/255, blue: 96/255))
                    .background(Color.white)
                    .padding(10)
            } else if currentSelection.chosen == box.index {
                Text(box.title)
                    .font(.custom("Ubuntu-Light", size: 18))
                    .background(Color(red: 52/255, green: 83/255, blue: 96/255))
                    .foregroundColor(Color.white)
                    .cornerRadius(20)
                    .padding(10)
            }
        }
    }
}

class cuisineChoice: ObservableObject {
    @Published var chosen = -1
    @Published var title = ""
    
    func reset() {
        chosen = -1
        title = ""
    }
    
    func edit(currChoice: String, array: [course]) {
        for k in 0...array.count-1{
            if array[k].title == currChoice {
                chosen = k
            }
        }
        title = currChoice
    }
}

struct StepperView: View {
    @Binding var serving: Int

        var body: some View {
            Stepper(onIncrement: {
                self.serving += 1
            print("onIncrement \(self.$serving)")
            }, onDecrement: {
            print("onDecrement\(self.$serving)")
                if self.serving > 0 {
                    self.serving -= 1
                }
            }, label: {
                HStack {
                    Text("Serving Size")
                        .font(.custom("Ubuntu-Light", size: 18))
                        .foregroundColor(Color(red: 204/255, green: 133/255, blue: 97/255))
                        .padding()
//                    Image(systemName: "person.2")
                    Text("\(serving)")
                        .font(.custom("Ubuntu-Light", size: 18))
                }
        })
    }
}

struct Trial_Previews: PreviewProvider {
    static var previews: some View {
        Trial(optionalrecipe: DecodedRecipe(), loaded: false, navigationBarTitle: "Trial")
    }
}

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
    
    
}

func arrayToString(array: [String]) -> String {
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

