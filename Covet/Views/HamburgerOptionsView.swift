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
            Section("My Covet Profile") {
                if auth.currentCovetUser != nil {
                    if let pending = auth.currentCovetUser!.pending_incoming {
                        if pending.count > 0 {
                            NavigationLink(
                                destination:
                                    UserManagerView(
                                        relationships: pending,
                                        navbarTitle: "Requested Friends/Followers"
                                    )
                                    .onDisappear {
                                        self.auth.refreshUser()
                                    }
                            ) {
                                Chip(
                                    preIcon: nil,
                                    text: " " + String(pending.count) + " ",
                                    color: Color.covetGreen()
                                )
                                .foregroundColor(Color.white)
                                Text("Follow and Friend Requests")
                            }
                        }
                    }
                    NavigationLink(destination: {
                        UserSettingsView(
                                                    mode: .Modify,
                                                    handle: user.username,
                                                    name: user.name ?? ""
                                                )                    }, label: {
                        Text("Manage my account")
                    })
                    Button(action: {
                        auth.logout()
                    }, label: {
                        Text("Logout")
                    })
                } else {
                    ProgressView()
                }
            }
            Section("Help", content: {
                NavigationLink(destination: FAQView()) {
                    Label("FAQ & How-To", systemImage: "questionmark.circle")
                }
            })
            Section("Compliance", content: {
                NavigationLink(destination: {
                    OpenSourceSoftware()
                        .navigationBarTitle("Thank you")
                }, label: {
                    Text("Open Source Software")
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
                            .foregroundColor(Color.red)
                    }
                })
            })
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
