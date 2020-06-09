//
//  ContentView.swift
//  Inventory
//
//  Created by Sven Iffland on 29.04.20.
//  Copyright © 2020 Sven Iffland. All rights reserved.
//

import SwiftUI
import CodeScanner

struct ContentView: View {
    @State private var searchQuery: String = ""
    @State private var isShowingScanner = false
    @State var showingAddScreen = false
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: Item.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Item.name, ascending: true)])
    var items: FetchedResults<Item>
    @FetchRequest(entity: Storage.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Storage.name, ascending: true)])
    var cases: FetchedResults<Storage>
    @FetchRequest(entity: Type.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Type.name, ascending: true)])
    var types: FetchedResults<Type>
    @State var searchId:String = ""
    var body: some View {
        TabView() {
            NavigationView{
                List{
                    HStack{
                        SearchBar(text: $searchQuery, placeholder: "Items suchen")
                        Button(action: {
                            self.isShowingScanner = true
                        }) {
                            Image(systemName: "qrcode.viewfinder")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        Divider()
                        Button("Abbrechen") {
                            UIApplication.shared.endEditing()
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .frame(height:40)
                    Button(action: {
                        for item in self.items {
                            item.nextCheckUp = Date()
                        }
                    try? self.managedObjectContext.save()
                    }) {
                        Text("Alle überprüfen")
                    }
                    .foregroundColor(.red)
                    if self.items.filter{$0.id == UUID(uuidString: searchId)}.count > 0 {
                        Section(header: Text("QR-Code")){
                            HStack{
                                Text("")
                                ForEach(self.items.filter{$0.id == UUID(uuidString: searchId)}, id:\.self){ item in
                                    NavigationLink(destination: ItemDetailView(newitem: item)){
                                        HStack{
                                            if item.type != nil {
                                                Circle()
                                                .frame(width:20, height: 20)
                                                    .foregroundColor(Color(red: item.type!.colorR, green: item.type!.colorG, blue: item.type!.colorB))
                                                .overlay(Circle()
                                                    .stroke(lineWidth: 2)
                                                    .foregroundColor(Color.primary))
                                            }
                                            Text(item.name ?? "undefined")
                                        }
                                    }
                                }
                                .onDelete(perform: deleteItems)
                                .listStyle(GroupedListStyle())
                            }
                            .foregroundColor(.green)
                        }
                    }
                    if !(self.items.filter{$0.nextCheckUp! <= Date() || $0.canBeUsedUp ? $0.supply >= Int64($0.supplyAlert) ? false : true : false}).isEmpty{
                        Section(header: Text("zu überprüfen oder fast Aufgebraucht").foregroundColor(.red)){
                            ForEach(self.items.filter{$0.nextCheckUp! <= Date() || $0.canBeUsedUp ? $0.supply >= Int64($0.supplyAlert) ? false : true : false}, id: \.self){ item in
                                NavigationLink(destination: ItemDetailView(newitem: item)){
                                    HStack{
                                        if item.type != nil {
                                            Circle()
                                            .frame(width:20, height: 20)
                                                .foregroundColor(Color(red: item.type!.colorR, green: item.type!.colorG, blue: item.type!.colorB))
                                            .overlay(Circle()
                                                .stroke(lineWidth: 2)
                                                .foregroundColor(Color.primary))
                                        }
                                        Text(item.name ?? "undefined")
                                    }
                                }
                            }
                            .onDelete(perform: deleteItems)
                            .listStyle(GroupedListStyle())
                        }
                    }
                    ForEach(cases, id:\.self){ storage in
                        Section(header: Text(storage.name ?? "undefined")) {
                            ForEach(self.items.filter{self.searchQuery.isEmpty ? true : $0.name!.lowercased().contains(self.searchQuery.lowercased())}.filter{$0.storage == storage}, id: \.self){ item in
                                NavigationLink(destination: ItemDetailView(newitem: item)){
                                    if item.type != nil {
                                        HStack{
                                            Circle()
                                            .frame(width:20, height: 20)
                                                .foregroundColor(Color(red: item.type!.colorR, green: item.type!.colorG, blue: item.type!.colorB))
                                            .overlay(Circle()
                                                .stroke(lineWidth: 2)
                                                .foregroundColor(Color.primary))
                                        }
                                        Text(item.name ?? "undefined")
                                    }
                                }
                            }
                            .onDelete(perform: self.deleteItems)
                            .listStyle(GroupedListStyle())
                        }
                    }
                    if !(self.items.filter{self.searchQuery.isEmpty ? true : $0.name!.lowercased().contains(self.searchQuery.lowercased())}.filter({$0.storage == nil})).isEmpty{
                        Section(header: Text("ohne Gruppe")) {
                            ForEach(self.items.filter{self.searchQuery.isEmpty ? true : $0.name!.lowercased().contains(self.searchQuery.lowercased())}.filter({$0.storage == nil}), id: \.self){ item in
                                NavigationLink(destination: ItemDetailView(newitem: item)){
                                    HStack{
                                        if item.type != nil {
                                            Circle()
                                            .frame(width:20, height: 20)
                                                .foregroundColor(Color(red: item.type!.colorR, green: item.type!.colorG, blue: item.type!.colorB))
                                            .overlay(Circle()
                                                .stroke(lineWidth: 2)
                                                .foregroundColor(Color.primary))
                                        }
                                        Text(item.name ?? "undefined")
                                    }
                                }
                            }
                            .onDelete(perform: deleteItems)
                            .listStyle(GroupedListStyle())
                        }
                    }
                }
                .navigationBarTitle(Text("Items"), displayMode: .automatic)
                .listStyle(GroupedListStyle())
                .navigationBarItems(
                    leading:
                    EditButton(),
                    trailing:
                    Button(action: {
                    self.showingAddScreen.toggle()
                    try? self.managedObjectContext.save()
                    }) {
                        Image(systemName: "plus")
                    })
                    .sheet(isPresented: $showingAddScreen) {
                        AddItemView().environment(\.managedObjectContext, self.managedObjectContext)
                }
            }
            .onDisappear{
                self.searchId = ""
            }
            .tabItem{ Text("Items") }
            .tag(0)
            TypesView()
                .tabItem{ Text("Kategorien") }
                .tag(1)
            StorageView()
                .tabItem{ Text("Gruppen") }
                .tag(2)
        }
        .sheet(isPresented: $isShowingScanner) {
            CodeScannerView(codeTypes: [.qr], completion: self.handleScan)
        }
    }
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
       self.isShowingScanner = false
       switch result {
       case .success(let code):
           let details = code.components(separatedBy: "\n")
           guard details.count == 1 else { return }

            searchId = details[0]
        
       case .failure(let error):
           print("Scanning failed")
       }
    }
    func deleteItems(at offsets: IndexSet) {
        for offset in offsets {
            let item = items[offset]
            managedObjectContext.delete(item)
        }
        try? managedObjectContext.save()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            return ContentView().environment(\.managedObjectContext, context)
    }
}
struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        init(text: Binding<String>) {
            _text = text
        }
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        return searchBar
    }
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
