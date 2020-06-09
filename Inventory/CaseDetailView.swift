//
//  CaseDetailView.swift
//  Inventory
//
//  Created by Sven Iffland on 10.05.20.
//  Copyright © 2020 Sven Iffland. All rights reserved.
//

import SwiftUI

struct CaseDetailView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var storage: Storage
    @FetchRequest(entity: Item.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Item.name, ascending: true)])
    var items: FetchedResults<Item>
    @State var name: String = ""
    var body: some View {
        VStack{
            TextField("Name", text: $name)
                .multilineTextAlignment(.center)
                .font(.custom("", size: 60))
            Spacer()
            List{
                ForEach(items.filter{
                    $0.storage == self.storage
                }, id:\.self){ content in
                    NavigationLink(destination: ItemDetailView(newitem: content)){
                        Text(content.name ?? "undefined")
                    }
                }
            }.listStyle(GroupedListStyle())
        }
        .onAppear{
            self.name = self.storage.name ?? ""
        }
        .onDisappear{
            self.storage.name = self.name
            try? self.managedObjectContext.save()
        }
    }
}

struct CaseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return CaseDetailView(storage: Storage(context: context)).environment(\.managedObjectContext, context)
    }
}
