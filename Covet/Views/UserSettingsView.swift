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
    case UpdatedProfile
    case FailedToUpdateProfile
}

struct UserSettingsView: View {

    @EnvironmentObject var auth: AuthService

    var mode: UserSettingsViewPresentationOptions;

    @State var actionState: UserProfileOperationState = .None

    @State var showLoadingToast: Bool = false
    @State var showProfileCreationErrorToast: Bool = false
    @State var errorToastExplanation: String? = nil

    @State var profile: CovetUser?;

    @State var handle: String;
    @State var name: String;

    var body: some View {
        VStack {
            ScrollView {
                CovetC(size: 64, text: nameToInitials(str: $name.wrappedValue))
                    .padding(Edge.Set.top, 2)
                    .padding(Edge.Set.bottom, 8)
                
                if mode == .NewSignup {
                    PromptedUserInput(prompt: "Username", placeholder: "", text: $handle,
                                      autocapitalization: UIKit.UITextAutocapitalizationType.none,
                                      autocorrect: false)
                }
                
                PromptedUserInput(prompt: "Name", placeholder: "", text: $name)
                
            }
            if ( actionState == .None ) {
                Group {
                    Button(
                        action: {
                            if self.mode == .NewSignup {
                                self.createProfile()
                            } else {
                                self.updateProfile()
                            }
                        },
                        label: {
                            Text("Save")
                                .padding(Edge.Set.top, 0)
                                .frame(maxWidth: .infinity)
                        }
                    )
                    .frame(width: self.getButtonWidth(), height: 52, alignment: Alignment.center)
                    .background(self.getButtonColor())
                    .foregroundColor(Color.white)
                    .disabled(!self.isInputComplete())
                }
                .frame(width: nil, height: 52, alignment: .top)
                if (self.mode == .Modify) {
                    Spacer()
                }
            }
        }
        .toast(isPresenting: $showLoadingToast) {
            AlertToast(
                type: .loading,
                title: getToastWorkingText(),
                subTitle: nil
            )
        }
        .toast(isPresenting: $showProfileCreationErrorToast) {
            AlertToast(type: .error(Color.red), title: "Oops!",
                       subTitle: "We weren't able to make your profile")
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Your Covet Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                self.mode == .NewSignup ? (
                    AnyView(Button(action: {
                        auth.logout()
                    }) {
                        Text("Logout")
                            .foregroundColor(Color.covetGreen())
                    })
                ): AnyView(EmptyView())
            }
        }
    }

    func getButtonWidth() -> CGFloat {
        if self.mode == .NewSignup {
            return .infinity
        } else {
            return 256.0
        }
    }

    func getToastWorkingText() -> String {
        return self.mode == .NewSignup ? "Creating Profile" : "Updating Profile"
    }

    func getButtonColor() -> Color {
        if (isInputComplete()) {
            return Color.covetGreen()
        } else {
            return Color.covetGreen().opacity(0.5)
        }
    }

    func isInputComplete() -> Bool {
        var complete = true
        if(self.mode == .NewSignup) {
            complete = complete && self.$handle.wrappedValue.count >= 3
        }
        complete = complete && self.$name.wrappedValue.count >= 1
        return complete
    }

    private func createProfile() {
        Task.detached {
            await self.updateUI(showLoadingToast: true, actionState: .CreatingProfile, profile: nil, errorToast: false)
            var usr: CovetUser? = nil
            do {
                let createdProfile = try await API.createProfile(
                    username: handle,
                    name: name,
                    bio: nil,
                    birthday: nil,
                    address: nil,
                    privateForFollowing: 0,
                    privateForFriending: 1
                )

                if createdProfile != nil {
                    usr = createdProfile
                }
            } catch {
                print(error)
            }

            await self.updateUI(
                showLoadingToast: false,
                actionState: usr == nil ? .FailedToCreateProfile : .CreatedProfile,
                profile: usr,
                errorToast: usr == nil
            )
        }
    }

    private func updateProfile() {
        Task.detached {
            await self.updateUI(showLoadingToast: true, actionState: .UpdatingProfile, profile: nil, errorToast: false)
            var usr: CovetUser? = nil
            do {
                let createdProfile = try await API.updateProfile(
                    originalUser: auth.currentCovetUser!,
                    name: name,
                    bio: nil,
                    birthday: nil,
                    address: nil,
                    privateForFollowing: 0,
                    privateForFriending: 1
                )

                if createdProfile != nil {
                    usr = createdProfile
                }
            } catch {
                print(error)
            }

            await self.updateUI(
                showLoadingToast: false,
                actionState: usr == nil ? .FailedToUpdateProfile : .UpdatedProfile,
                profile: usr == nil ? (self.profile ?? nil) : usr,
                errorToast: usr == nil
            )
        }
    }

    private func updateUI(showLoadingToast: Bool, actionState: UserProfileOperationState, profile: CovetUser?, errorToast: Bool) async {

        // Local page state
        self.showLoadingToast = showLoadingToast
        self.actionState = actionState
        self.profile = profile
        self.showProfileCreationErrorToast = errorToast

        // Global auth/profile state
        // while making sure the extension token gets set
        auth.refreshUser(first: true)

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
        return components[0].firstCharacter().uppercased()
    }
    else {
        let firstComponent = components[0]
        let lastComponent = components[components.count - 1]
        return firstComponent.firstCharacter().uppercased() +
            lastComponent.firstCharacter().uppercased()
    }
}

func getInitials(str: String) -> String {
    let components = str.components(separatedBy: " ").filter { s in
        return s.count > 0
    }
    if components.count == 0 {
        return ""
    }
    else if components.count == 1 {
        if components[0].count == 1 {
            return components[0].firstCharacter().uppercased()
        } else {
            return components[0].firstNCharacters(n: 2).uppercased()
        }
    }
    else {
        return (
            components[0].firstCharacter().uppercased() +
            components[components.count-1].firstCharacter().uppercased()
        )
    }
}

struct UserSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        UserSettingsView(
            mode: .NewSignup,
            handle: "@brendanmanning",
            name: "Brendan"
        )
    }
}
