//
//  AddTypeView.swift
//  Inventory
//
//  Created by Sven Iffland on 08.05.20.
//  Copyright © 2020 Sven Iffland. All rights reserved.
//

import SwiftUI

struct AddTypeView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var name: String = ""
    @State private var colorR = 0.1
    @State private var colorG = 0.1
    @State private var colorB = 0.1
    var body: some View {
        NavigationView{
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
            }
            .navigationBarTitle(Text("Bearbeiten"), displayMode: .inline)
            .navigationBarItems(
                leading:
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Abbrechen")
                },
                trailing:
                Button(action: {
                    let newType = Type(context: self.managedObjectContext)
                    newType.name =  self.name
                    newType.colorR = self.colorR
                    newType.colorG = self.colorG
                    newType.colorB = self.colorB
                    try? self.managedObjectContext.save()
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Hinzufügen").bold()
                }
            )
        }
    }
}

struct AddTypeView_Previews: PreviewProvider {
    static var previews: some View {
        AddTypeView()
    }
}

