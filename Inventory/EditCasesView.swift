//
//  StorageView.swift
//  Inventory
//
//  Created by Sven Iffland on 10.05.20.
//  Copyright © 2020 Sven Iffland. All rights reserved.
//

import SwiftUI

struct EditCasesView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest(entity: Storage.entity(), sortDescriptors: [])
    var cases: FetchedResults<Storage>
    @State var hideBackButton = false
    @State var searchQuery = ""
    @State var showAlert = false
    @State var newItem = ""
    var body: some View {
        NavigationView{
            List{
                HStack{
                    SearchBar(text: $searchQuery, placeholder: "Gruppe suchen")
                    Button("Abbrechen") {
                        UIApplication.shared.endEditing()
                    }.foregroundColor(.accentColor)
                }
                .frame(height:40)
                HStack{
                    TextField("neue Gruppe", text: $newItem)
                    Button(action: {
                        let newCase = Storage(context: self.managedObjectContext)
                        newCase.name = self.newItem
                        self.newItem = ""
                    try? self.managedObjectContext.save()
                    }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .frame(height:30)
                ForEach(self.cases, id:\.self){ storage in
                    NavigationLink(destination: CaseDetailView(storage: storage)){
                        storage.name != nil ? Text(storage.name!) : Text("kein Name").italic()
                    }
                    .accentColor(.primary)
                }
                .onDelete(perform: deleteStorage)
                .listStyle(GroupedListStyle())
            }
            .navigationBarTitle(Text("Gruppen"), displayMode: .automatic)
            .listStyle(GroupedListStyle())
            .navigationBarItems(
                leading:
                EditButton()
            )
        }
        .navigationBarTitle(Text("Bearbeiten"), displayMode: .inline)
        .navigationBarItems(
            trailing:
            Button(action: {
                try? self.managedObjectContext.save()
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Speichern")
            }
            .buttonStyle(BorderlessButtonStyle())
        )
    }
    func deleteStorage(at offsets: IndexSet) {
        for offset in offsets {
            let storage = cases[offset]
            managedObjectContext.delete(storage)
        }
        try? managedObjectContext.save()
    }
}

struct EditCasesView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return EditCasesView().environment(\.managedObjectContext, context)
    }
}
