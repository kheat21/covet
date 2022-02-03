//
//  HamburgerOptionsView.swift
//  Covet
//
//  Created by Covet on 1/31/22.
//

import SwiftUI

struct HamburgerOptionsView: View {
    
    @EnvironmentObject var auth: AuthService
    @EnvironmentObject var settings: LocalSettingsService
    
    @State var user: CovetUser;
    @State var deletingAccount: Bool = false
    @State var shouldShowDeleteAccount: Bool = false
    
    @State var showDeveloperOptions: Bool = false
    
    var body: some View {
        List {
            if auth.currentCovetUser != nil {
                if let pending = auth.currentCovetUser!.pending_incoming {
                    if pending.count > 0 {
                        NavigationLink(
                            destination: UserManagerView(
                                relationships: pending,
                                navbarTitle: "Requested Friends/Followers"
                            )) {
                            Text("Follow and Friend Requests")
                        }
                    }
                }
                NavigationLink(destination: {
                    UserSettingsView(
                        mode: UserSettingsViewPresentationOptions.Modify,
                        handle: user.username,
                        name: user.name ?? "",
                        birthday: nil, // self.user.birthday.p ?? Date(),
                        privateForFollowing: user.privateForFollowing == 1,
                        privateForFriending: user.privateForFriending == 1
                    )
                }, label: {
                    Text("Manage my account")
                })
                Button(action: {
                    self.shouldShowDeleteAccount = true
                }, label: {
                    if self.deletingAccount {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Text("Delete my account")
                    }
                })
                Button(action: {
                    auth.logout()
                }, label: {
                    Text("Logout")
                })
                NavigationLink(destination: {
                    OpenSourceSoftware()
                }, label: {
                    Text("Open Source Software")
                })
            } else {
                ProgressView()
            }
            PromptedRadioInput(
                prompt: "Show developer options",
                toggleBackgroundColor: nil,
                value: $showDeveloperOptions,
                leftEdgePadding: 0
            )
            if showDeveloperOptions {
                PromptedRadioInput(
                    prompt: "Show alert when user refreshing",
                    toggleBackgroundColor: Color.gray,
                    value: $settings.showNotificationWhenRefreshingUser,
                    leftEdgePadding: 0
                )
                PromptedRadioInput(
                    prompt: "Show error if user refresh fails",
                    toggleBackgroundColor: Color.gray,
                    value: $settings.showErrorWhenUserRefreshFails,
                    leftEdgePadding: 0
                )
            }
        }
        .confirmationDialog("Permanently delete your account?", isPresented: $shouldShowDeleteAccount) {
            Button("Delete", role: .destructive) {
                Task {
                    self.deletingAccount = true
                    do {
                        if let status = try await API.requestDeletion() {
                            if status.success {
                                auth.logout()
                            }
                        }
                    } catch {}
                    self.deletingAccount = false
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Your Covet profile will be deleted")
        }
    }
}

//struct HamburgerOptionsView_Previews: PreviewProvider {
//    static var previews: some View {
//        HamburgerOptionsView()
//    }
//}
