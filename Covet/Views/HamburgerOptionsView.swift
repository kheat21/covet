//
//  HamburgerOptionsView.swift
//  Covet
//
//  Created by Covet on 1/31/22.
//

import SwiftUI

struct HamburgerOptionsView: View {
    
    @State var user: CovetUser;
//    @Binding var shouldShowSavingToast: Bool
//    @Binding var shouldShowErrorToast: Bool
//    @Binding var errorToastContents: String
    
    var body: some View {
        List {
            if let pendingRelationships = self.user.pending {
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
                    handle: self.user.username,
                    name: self.user.name ?? "",
                    birthday: nil, // self.user.birthday.p ?? Date(),
                    privateForFollowing: self.user.privateForFollowing == 1,
                    privateForFriending: self.user.privateForFriending == 1
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
                AuthService.shared.logout()
            }, label: {
                Text("Logout")
            })
            NavigationLink(destination: {
                OpenSourceSoftware()
            }, label: {
                Text("Open Source Software")
            })
        }
    }
}

//struct HamburgerOptionsView_Previews: PreviewProvider {
//    static var previews: some View {
//        HamburgerOptionsView()
//    }
//}
