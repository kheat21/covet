//
//  UserSettingsView.swift
//  Covet
//
//  Created by Brendan Manning on 11/29/21.
//

import SwiftUI

enum UserSettingsViewPresentationOptions {
    case NewSignup
    case Modify
}

struct UserSettingsView: View {
    
    var mode: UserSettingsViewPresentationOptions;
    
    @State var handle: String;
    @State var name: String;
    @State var username: String = ""
    @State var bio: String = ""
    
    @State var birthdaySet: Bool = false
    @State var birthday: Date;
    
    @State var privateForFollowing: Bool;
    @State var privateForFriending: Bool;
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    CovetC(size: 64, text: nameToInitials(str: $name.wrappedValue))
                        .padding(Edge.Set.top, 2)
                        .padding(Edge.Set.bottom, 8)
                    if mode == .NewSignup {
                        PromptedUserInput(prompt: "Handle", placeholder: "This is your screen name", text: $handle)
                    }
                    PromptedUserInput(prompt: "Name", placeholder: "Pleased to meet you 😃", text: $name)
                    PromptedUserInput(prompt: "Bio", placeholder: "Something witty", text: $bio)
                    PromptedDateInput(prompt: "Birthday", noDateSelectedMessage: "Select", buttonColor: Color.green, date: $birthday, dateSet: $birthdaySet)
                    PromptedRadioInput(prompt: "Require permission to follow me", toggleBackgroundColor: nil, value: $privateForFollowing)
                    PromptedRadioInput(prompt: "Require permission to become my friend", toggleBackgroundColor: nil, value: $privateForFriending)
                }
                Group {
                    Button(
                        action: {
                            print("Signup")
                        },
                        label: {
                            Text("Save")
                                .padding(Edge.Set.top, 0)
                                .frame(maxWidth: .infinity)
                        }
                    )
                        .frame(width: .infinity, height: 52, alignment: Alignment.center)
                        .background(Color.green)
                        .foregroundColor(Color.white)
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Your Covet Profile")
        }
    }
}
                           
func nameToInitials(str: String) -> String {
    let components = str.components(separatedBy: " ").filter { s in
        return s.count > 0
    }
    if components.count == 0 {
        return ""
    }
    else if components.count == 1 {
        return components[0].firstCharacter()
    }
    else {
        let firstComponent = components[0]
        let lastComponent = components[components.count - 1]
        return firstComponent.firstCharacter() + lastComponent.firstCharacter()
    }
}

struct UserSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        UserSettingsView(
            mode: .NewSignup,
            handle: "@brendanmanning",
            name: "Brendan",
            birthday: Date(),
            privateForFollowing: false,
            privateForFriending: true
        )
    }
}
