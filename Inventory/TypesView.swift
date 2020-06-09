//
//  EditTypesView.swift
//  Inventory
//
//  Created by Sven Iffland on 08.05.20.
//  Copyright © 2020 Sven Iffland. All rights reserved.
//
import SwiftUI

struct TypesView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    @State var showingAddScreen = false
    @State var searchQuery: String = ""
    @FetchRequest(entity: Type.entity(), sortDescriptors: [])
    var types: FetchedResults<Type>
    var body: some View {
        NavigationView{
            List{
                HStack{
                    SearchBar(text: $searchQuery, placeholder: "Kategorien succhen")
                    Button("Abbrechen") {
                        UIApplication.shared.endEditing()
                    }
                }
                .frame(height: 40)
                ForEach(types, id: \.self){ type in
                     NavigationLink(destination: TypeDetailView(newType: type)){
                        HStack{
                            Circle()
                                .frame(width:20, height: 20)
                                .foregroundColor(Color(red: type.colorR, green: type.colorG, blue: type.colorB))
                                .overlay(Circle().stroke(lineWidth: 2).foregroundColor(Color.primary))
                            Text(type.name ?? "undefined")
                        }
                    }
                }.onDelete(perform: deleteTypes)
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("Kategorien"), displayMode: .automatic)
            .navigationBarItems(
                leading:
                EditButton(),
                trailing:
                Button(action: {
                self.showingAddScreen.toggle()
            }) {
                Image(systemName: "plus")
            }
                .buttonStyle(BorderlessButtonStyle())
                .sheet(isPresented: $showingAddScreen){
                    AddTypeView().environment(\.managedObjectContext, self.managedObjectContext)
                }
            )
        }
    }
    func deleteTypes(at offsets: IndexSet) {
        for offset in offsets {
            let type = types[offset]
            managedObjectContext.delete(type)
        }
        try? managedObjectContext.save()
    }
}

struct TypesView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return EditTypesView().environment(\.managedObjectContext, context)
    }
}
