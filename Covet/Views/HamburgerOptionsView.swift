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
//    @Binding var shouldShowSavingToast: Bool
//    @Binding var shouldShowErrorToast: Bool
//    @Binding var errorToastContents: String
    
    @State var showDeveloperOptions: Bool = false
    
    var body: some View {
        List {
            if let user = auth.currentCovetUser {
                if let pendingRelationships = user.pending {
                    if pendingRelationships.count > 0 {
                        NavigationLink(
                            destination: UserManagerView(
                                relationships: pendingRelationships,
                                navbarTitle: "Requested Friends/Followers"
                                //,
    //                            shouldShowSavingToast: $shouldShowSavingToast,
    //                            shouldShowErrorToast: $shouldShowErrorToast,
    //                            errorToastContents: $errorToastContents
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
                    print("Delete my account")
                }, label: {
                    Text("Delete my account")
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
    
    }
}

//struct HamburgerOptionsView_Previews: PreviewProvider {
//    static var previews: some View {
//        HamburgerOptionsView()
//    }
//}
