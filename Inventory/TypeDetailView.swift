//
//  TypeDetailView.swift
//  Inventory
//
//  Created by Sven Iffland on 09.05.20.
//  Copyright © 2020 Sven Iffland. All rights reserved.
//

import SwiftUI

struct TypeDetailView: View {
    @ObservedObject var type:Type
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var name: String = ""
    @State private var colorR = 0.1
    @State private var colorG = 0.1
    @State private var colorB = 0.1
    @FetchRequest(entity: Item.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Item.name, ascending: true)])
    var items: FetchedResults<Item>
    init(newType: Type) {
        self.type = newType
    }
    var body: some View {
        VStack{
            Form{
                Section{
                    HStack{
                        Spacer()
                        Circle()
                            .frame(width:20)
                            .foregroundColor(Color(red: colorR, green: colorG, blue: colorB))
                            .overlay(Circle().stroke(lineWidth: 2).foregroundColor(Color.primary))
                        TextField("Name", text: $name)
                            .multilineTextAlignment(.leading)
                            .font(.custom("", size: 40))
                            .frame(width:UIScreen.main.bounds.width/1.8)
                    }
                }//Name Section
                Section{
                    VStack{
                        HStack{
                            Slider(value: $colorR)
                                .background(LinearGradient(gradient: Gradient(colors: [.red,.black]), startPoint: .trailing, endPoint: .leading).clipShape(RoundedRectangle(cornerRadius: 10)).frame(height:4)).accentColor(.clear)
                                .padding(.horizontal)
                            Text("\(Int(colorR * 255))").frame(width:35)
                        }
                        HStack{
                            Slider(value: $colorG)
                                .background(LinearGradient(gradient: Gradient(colors: [.green,.black]), startPoint: .trailing, endPoint: .leading).clipShape(RoundedRectangle(cornerRadius: 10)).frame(height:4)).accentColor(.clear)
                                .padding(.horizontal)
                            Text("\(Int(colorG * 255))").frame(width:35)
                        }
                        HStack{
                            Slider(value: $colorB)
                                .background(LinearGradient(gradient: Gradient(colors: [.blue,.black]), startPoint: .trailing, endPoint: .leading).clipShape(RoundedRectangle(cornerRadius: 10)).frame(height:4)).accentColor(.clear)
                                .padding(.horizontal)
                            Text("\(Int(colorB * 255))").frame(width:35)
                        }
                    }
                }//RGB Section
                Section{
                    ForEach(items.filter{
                        $0.type == self.type
                    }, id:\.self){ content in
                        NavigationLink(destination: ItemDetailView(newitem: content)){
                            Text(content.name ?? "undefined")
                        }
                    }.listStyle(GroupedListStyle())
                }
            }
            .onAppear{
                self.name = self.type.name ?? ""
                self.colorR = self.type.colorR
                self.colorG = self.type.colorG
                self.colorB = self.type.colorB
            }
            .onDisappear{
                self.type.name =  self.name
                self.type.colorR = self.colorR
                self.type.colorG = self.colorG
                self.type.colorB = self.colorB
                try? self.managedObjectContext.save()
            }
        }
    }
}

struct TypeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return TypeDetailView(newType: Type(context: context)).environment(\.managedObjectContext, context)    }
}
