//
//  UserSettingsView.swift
//  Covet
//
//  Created by Brendan Manning on 11/29/21.
//

import SwiftUI

struct UserSettingsView: View {
    
    @State var handle: String;
    @State var name: String;
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    HStack {
                        Text("Handle")
                        TextField("@yourhandle", text: $handle)
                            .padding(EdgeInsets(top: 8, leading: 16,
                                                bottom: 8, trailing: 16))
                            .background(Color.white)
                            .shadow(color: Color.gray.opacity(0.4),
                                    radius: 3, x: 1, y: 2)
                    }.padding(Edge.Set.horizontal, 16)
                    
                    HStack {
                        Text("Your Name")
                        TextField("Your Name", text: $name)
                            .padding(EdgeInsets(top: 8, leading: 16,
                                                bottom: 8, trailing: 16))
                            .background(Color.white)
                            .shadow(color: Color.gray.opacity(0.4),
                                    radius: 3, x: 1, y: 2)
                    }.padding(Edge.Set.horizontal, 16)
                    
                }
                
                Button(
                    action: {
                        print("Signup")
                    },
                    label: {
                        Text("Save")
                            .padding(Edge.Set.top, 24)
                            .frame(maxWidth: .infinity)
                    }
                )
                    .frame(width: .infinity, height: 30, alignment: Alignment.center)
                    .background(Color.green)
                    .foregroundColor(Color.white)
                
            }
            .navigationTitle("Your Covet Profile")
        }
    }
}

struct UserSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        UserSettingsView(handle: "@brendanmanning", name: "Brendan")
    }
}
