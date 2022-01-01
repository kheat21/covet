//
//  UserSettingsView.swift
//  Covet
//
//  Created by Brendan Manning on 11/29/21.
//

import AlertToast
import Firebase
import SwiftUI

enum UserSettingsViewPresentationOptions {
    case NewSignup
    case Modify
}

enum UserProfileOperationState {
    case None
    case CreatingProfile
    case CreatedProfile
    case FailedToCreateProfile
    case UpdatingProfile
    //    case UpdatedProfile
    case FailedToUpdateProfile
}

struct UserSettingsView: View {
    
    var mode: UserSettingsViewPresentationOptions;
    
    @State var actionState: UserProfileOperationState = .None
    
    @State var showLoadingToast: Bool = false
    @State var showProfileCreationErrorToast: Bool = false
    
    @State var profile: CovetUser?;
    
    @State var handle: String;
    @State var name: String;
    @State var bio: String = ""
    @State var address: String?
    
    @State var birthdaySet: Bool = false
    @State var birthday: Date;
    
    @State var privateForFollowing: Bool;
    @State var privateForFriending: Bool;
    
    var userCreatedCallback: ((_: CovetUser) -> Void)?;
    
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
                if ( actionState == .None ) {
                    Group {
                        Button(
                            action: {
                                Task {
                                    do {
                                        showLoadingToast = true
                                        actionState = .CreatingProfile
                                        let createdProfile = try await API.createProfile(
                                            username: handle,
                                            name: name,
                                            birthday: birthdaySet ? birthday : nil,
                                            address: address
                                        )
                                        showLoadingToast = false
                                        if createdProfile != nil {
                                            actionState = .CreatedProfile
                                            profile = createdProfile
                                            if let callback = userCreatedCallback {
                                                callback(profile!)
                                            }
                                        } else {
                                            actionState = .FailedToCreateProfile
                                            showProfileCreationErrorToast = true
                                        }
                                    } catch {
                                        showLoadingToast = false
                                        showProfileCreationErrorToast = true
                                        actionState = .FailedToCreateProfile
                                    }
                                }
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
            }
            .toast(isPresenting: $showLoadingToast) {
                AlertToast(type: .loading, title: "Creating Profile", subTitle: nil)
            }
            .toast(isPresenting: $showProfileCreationErrorToast) {
                AlertToast(type: .error(Color.red), title: "Oops!", subTitle: "We weren't able to make your profile")
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Your Covet Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        AuthService.shared.logout()
                    }) {
                        Text("Logout")
                    }
                }
            }
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

//func createProfile(username: String, name: String?, birthday: Date?, address: String?, profile: State<CovetUser?>) -> Void {
//    Task {
//        do {
//            profile. = try await API.createProfile(
//                username: username,
//                name: name,
//                birthday: birthday,
//                address: address
//            )
//        } catch {
//
//        }
//    }
//}

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
