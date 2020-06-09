//
//  ItemDetail.swift
//  Inventory
//
//  Created by Sven Iffland on 29.04.20.
//  Copyright © 2020 Sven Iffland. All rights reserved.
//

import SwiftUI
import CoreData
import CoreImage.CIFilterBuiltins

struct ItemDetailView: View {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    @ObservedObject var item: Item
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var isSharing = false
    @State var showCategoryEdit = false
    @State private var showingEditScreen = false
    @State private var showTypeWheel = false
    @State private var canBeUsedUp: Bool = false
    @State private var condition = 1.0
    @State private var itemDescription: String = ""
    @State private var name:String = ""
    @State private var nextCheckUp: Date = Date()
    @State private var supply: Int64 = 1
    @State private var stringCondition = "Good"
    @State private var supplyString =  "1"
    @State private var lastCheckUp: Date?
    @State private var categoryIndex: Type?
    @State private var updated:Bool = false
    @State private var caseIndex: Storage?
    @State private var supplyAlert: Int32  = 10
    @State private var supplyAlertString: String = "10"
    let conditionArr = ["Sehr gut","gut","befriedigend","ausreichend","mangelhaft","ungenügend"]
    @FetchRequest(entity: Storage.entity(), sortDescriptors: [])
    var cases: FetchedResults<Storage>
    @FetchRequest(entity: Type.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Type.name, ascending: true)])
    var types: FetchedResults<Type>
    let timeFormatter = DateFormatter()
    let dateFormatter = DateFormatter()
    let conditions = ["Perfect","Very good","Good","Ok","Not Great","Barely usable","unusable"]
    init(newitem: Item) {
        timeFormatter.dateFormat = "HH:mm"
        dateFormatter.dateFormat = "dd.MM.yyyy"
        item = newitem
    }
    var body: some View {
        Form{
            Section(header: Text("Name")){
                TextField("Name", text: $name)
            }//Name Section
            Section(header: Text("Beschreibung")){
                Button("Fertig") {
                    UIApplication.shared.endEditing()
                }
                MultilineTextField("Beschreibung", text: $itemDescription)
            }//Description Section
            Section(header: Text("Bestand")){
                Toggle(isOn: $canBeUsedUp) {
                    Text("Verbrauchsmaterial")
                }
                if canBeUsedUp {
                    Stepper(value: $supply, in: 0...999999,onEditingChanged: {_ in self.supplyString = String(self.supply)}) {
                        HStack{
                            Text("Bestand:")
                            TextField("Bestand", text: $supplyString
                                ,onCommit: {
                                    if Int64(self.supplyString) != nil && Int(self.supplyString) ?? 1000000 < 1000000{
                                        self.supply = Int64(self.supplyString)!
                                    }
                                    else {
                                        self.supplyString = "\(self.supply)"
                                    }
                                }
                            )
                        }
                    }
                    Stepper(value: $supplyAlert, in: 0...999999,onEditingChanged: {_ in self.supplyAlertString = String(self.supplyAlert)}) {
                        HStack{
                            Text("Alarm bei:")
                            TextField("Bestand", text: $supplyAlertString
                                ,onCommit: {
                                    if Int64(self.supplyString) != nil && Int(self.supplyAlertString) ?? 1000000 < 1000000{
                                        self.supplyAlert = Int32(self.supplyAlertString)!
                                    }
                                    else {
                                        self.supplyAlertString = "\(self.supplyAlert)"
                                    }
                                }
                            )
                        }
                    }
                }
            }//Supply Section
            Section(header: Text("Zustand")){
                HStack{
                    Text("Zustand: ")
                    Text("\(conditionArr[Int((1-condition)*5+0.5)])").foregroundColor(Color(red: -pow(condition+0.25,5)+0.9, green: pow(1.7,condition)-1, blue: 0))
                }
                Slider(value: $condition)
                    .background(LinearGradient(gradient: Gradient(colors: [.green,.red]), startPoint: .leading, endPoint: .trailing).clipShape(RoundedRectangle(cornerRadius: 10)).frame(height:3)).accentColor(.clear)
            
            }//condition Section
            Section(header: Text("Check-Up")){
                if lastCheckUp != nil{
                    Text("letztes Check-Up am \(dateFormatter.string(from: self.lastCheckUp!)) um \(timeFormatter.string(from: self.lastCheckUp!))")
                }
                Button(action: {
                    self.lastCheckUp = Date()
                    self.nextCheckUp = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? self.nextCheckUp
                }) {
                    Text("Überpruft")
                }
                DatePicker(selection: $nextCheckUp, displayedComponents: .date){
                    Text("Nächste Überprüfung:")
                }.accentColor(.red)
            }//Dates Section
            Section(header: Text("Kategorie")){
                Picker(selection: $categoryIndex, label: Text("Kategorie")) {
                    Text("keine Kategorie").tag(nil as Type?)
                    ForEach(types, id:\.self){ type in
                        HStack{
                            Circle()
                                .frame(width:30, height: 30)
                                .foregroundColor(Color(red: type.colorR, green: type.colorG, blue: type.colorB))
                                .overlay(Circle()
                                    .stroke(lineWidth: 2)
                                    .foregroundColor(Color.primary))
                            Text(type.name ?? "undefined")
                        }.tag(type as Type?)
                    }
                }
                HStack{
                    Button(action: {
                        self.showingEditScreen.toggle()
                    }) {
                    Text("Kategorien bearbeiten")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .sheet(isPresented: $showingEditScreen){
                        EditTypesView().environment(\.managedObjectContext, self.managedObjectContext)
                    }
                }
            }//Category Section
            Section(header: Text("Gruppe")){
                Picker(selection: $caseIndex, label: Text("Case: ")) {
                    Text("kein Case").tag(nil as Storage?)
                    ForEach(cases, id: \.self){ storage in
                        Text(storage.name ?? "undefined").tag(storage as Storage?)
                    }
                }
                HStack{
                    Button(action: {
                        self.showCategoryEdit.toggle()
                    }) {
                        Text("Cases bearbeiten")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .sheet(isPresented: $showCategoryEdit){
                        EditCasesView().environment(\.managedObjectContext, self.managedObjectContext)
                    }
                }
            }//Case Section
            Section(header: Text("QR-Code")){
                Image(uiImage: self.generateQRCode(from: "\(self.item.id ?? UUID(uuidString: ""))"))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                HStack{
                    Button(action: {
                        self.item.id = UUID()
                    }) {
                    Text("QR-Code erneuern")
                    }.buttonStyle(BorderlessButtonStyle())
                    Spacer()
                    Button(action: {
                        let imageSaver = ImageSaver()
                        imageSaver.writeToPhotoAlbum(image: self.generateQRCode(from: "\(self.item.id!)"))
                    }) {
                    Text("In Fotos speichern")
                    }.buttonStyle(BorderlessButtonStyle())
                }
            }
        }
        .onAppear{
            if self.item.id == nil{
                self.item.id = UUID()
            }
            if !self.updated {
                self.canBeUsedUp = self.item.canBeUsedUp
                self.condition = self.item.condition
                self.itemDescription = self.item.itemDescription ?? ""
                self.name = self.item.name ?? ""
                self.nextCheckUp = self.item.nextCheckUp ?? Date()
                self.supply = self.item.supply
                self.lastCheckUp = self.item.lastCheckUp
                self.supplyString = String(self.item.supply)
                self.categoryIndex = self.item.type
                self.caseIndex = self.item.storage
                self.supplyAlert = self.item.supplyAlert
                self.supplyAlertString = String(self.item.supplyAlert)
                self.updated = true
            }
        }
        .onDisappear{
            self.item.canBeUsedUp = self.canBeUsedUp
            self.item.condition = self.condition
            self.item.itemDescription = self.itemDescription
            self.item.lastCheckUp = Date()
            self.item.name = self.name
            self.item.nextCheckUp = self.nextCheckUp
            self.item.supply = self.canBeUsedUp ? self.supply : 1
            self.item.type = self.categoryIndex
            self.item.storage = self.caseIndex
            self.item.supplyAlert = self.supplyAlert
            try? self.managedObjectContext.save()
        }
    }
    func generateQRCode(from string: String) -> UIImage {
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

struct ItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return ItemDetailView(newitem: Item(context: context)).environment(\.managedObjectContext, context)
    }
}

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}

