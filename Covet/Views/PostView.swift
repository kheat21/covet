//
//  PostView.swift
//  Covet
//
//  Created by Covet on 1/24/22.
//

import AlertToast
import Foundation
import SwiftUI

struct PostView: View {
    
    @EnvironmentObject var auth: AuthService
    @Environment(\.presentationMode) var presentationMode
    
    @State var post: Post
    @State var isOwnPost: Bool = false
    
    @State var isLikedStatusLoading: Bool = true
    @State var isLikedStatusSaving: Bool = false
    @State var liked: Bool = false
    
    @State var showingShareActionSheet: Bool = false
    @State var showingRecovetActionSheet: Bool = false
    @State var showingAddressCopiedToast: Bool = false
    @State var showingNoAddressToCopyToast: Bool = false
    
    @State var isDeleting: Bool = false
    @State var errorDeleting: Bool = false
    @State var showingDeleteConfirmMessage: Bool = false
    
    @State var isReporting: Bool = false
    @State var errorReporting: Bool = false
    @State var showReportSuccessfulToast: Bool = false
    @State var showingReportConfirmMessage: Bool = false
    
    func isBusy() -> Bool {
        return (
            self.isLikedStatusLoading ||
            self.isLikedStatusSaving ||
            self.isDeleting ||
            self.isReporting
        )
    }
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Spacer().frame(width: 125)
                        Button {
                            print("Clicked")
                            if !self.isBusy() {
                                self.toggleLike(currentLiked: self.liked)
                            }
                        } label: {
                            if self.isLikedStatusLoading {
                                EmptyView()
                            } else if self.isLikedStatusSaving {
                                ProgressView()
                            } else {
                                self._likeButtonImage()
                                    .foregroundColor(
                                        self.isLikedStatusLoading
                                            ? Color.clear : Color.black
                                    )
                            }
                        }
                        Button {
                            self.showingShareActionSheet = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(Color.black)
                        }
                        Button {
                            self.showingRecovetActionSheet = true
                        } label: {
                            Image("Recovet")
                        }
                        Button {
                            if let postUser = self.post.user {
                                if let address = postUser.address {
                                    UIPasteboard.general.string = address
                                    self.showingAddressCopiedToast = true
                                } else {
                                    self.showingNoAddressToCopyToast = true
                                }
                            }
                            
                        } label: {
                            Image(systemName: "gift").foregroundColor(Color.black)
                        }
                        if self.isOwnPost {
                            if self.isDeleting {
                                ProgressView()
                            } else {
                                Button {
                                    self.showingDeleteConfirmMessage = true
                                } label: {
                                    Image(systemName: "trash").foregroundColor(Color.red)
                                }
                            }
                        } else {
                            if self.isReporting {
                                ProgressView()
                            } else {
                                Button {
                                    self.showingReportConfirmMessage = true
                                } label: {
                                    Image(systemName: "flag").foregroundColor(Color.red)
                                }
                            }
                        }
                    }
                    .frame(height: 50, alignment: Alignment.trailing)
                    .zIndex(2)
                    PostDisplay(post: self.post)
                    Spacer() //.frame(height: 40)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if let u = self.post.user {
                            makeCovetC(size: 36, user: u)
                        } else {
                            EmptyView()
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Image("Covet_Logo_Colored")
                            .resizable()
                            .scaledToFit()
                            .frame(width: nil, height: 20, alignment: Alignment.center)
                    }
                }
            }
            .toast(isPresenting: self.$showingAddressCopiedToast, duration: 2, tapToDismiss: true, alert: {
                AlertToast(displayMode: .banner(.pop), type: AlertToast.AlertType.complete(Color.covetGreen()), title: "Copied Address", subTitle: "Now use that to checkout on the merchant's website", style: nil)
            }, onTap: nil, completion: {
                self.openURL()
            })
            .toast(isPresenting: self.$showingNoAddressToCopyToast, duration: 5, tapToDismiss: true, alert: {
                AlertToast(displayMode: .banner(.pop), type: AlertToast.AlertType.complete(Color.red), title: "No address available", subTitle: "You'll have to ask your friend", style: nil)
            }, onTap: nil, completion: {
                self.openURL()
            })
            .toast(isPresenting: self.$errorDeleting, duration: 2, tapToDismiss: true, alert: {
                AlertToast(displayMode: .alert, type: .error(Color.red), title: "Could not delete", subTitle: "Try again later", style: nil)
            })
            .toast(isPresenting: self.$errorReporting, duration: 2, tapToDismiss: true, alert: {
                AlertToast(displayMode: .alert, type: .error(Color.red), title: "Could not report", subTitle: "Try again later / Did you already report?", style: nil)
            })
            .toast(isPresenting: self.$showReportSuccessfulToast, duration: 2, tapToDismiss: true, alert: {
                AlertToast(displayMode: .alert, type: .complete(Color.green), title: "Reported", subTitle: nil, style: nil)
            })
            .sheet(isPresented: $showingShareActionSheet) {
                PostShareSheet(activityItems: [
                    self.post.products![0].link
                ])
            }
            .sheet(isPresented: $showingRecovetActionSheet, onDismiss: nil, content: {
                RecovetView(post: self.post)
            })
            .confirmationDialog("Delete post?", isPresented: $showingDeleteConfirmMessage, actions: {
                Button("Delete", role: .destructive) {
                    doPostDelete()
                }
                Button("Cancel", role: .cancel) { }
            })
            .confirmationDialog("Report post?", isPresented: $showingReportConfirmMessage, actions: {
                Button("Report", role: .destructive) {
                    doPostReport()
                }
                Button("Cancel", role: .cancel) { }
            })
            .task {
                do {
                    if let likeStatus = try await API.likes(post_id: self.post.id) {
                        print(likeStatus)
                        self.liked = likeStatus.likes
                        self.isLikedStatusLoading = false
                    }
                } catch {}
            }
        }
    
    }
    
    private func doPostDelete() {
        if self.isBusy() { return }
        Task.detached {
            await self.setUIForDeleting(deleting: true, error: nil)
            let deleted = await API.delete(post_id: self.post.id)
            if deleted {
                await auth.refreshUser()
                await self.setUIForDeleting(deleting: false, error: nil)
                await self.dismissSelf()
            } else {
                await self.setUIForDeleting(deleting: false, error: true)
            }
        }
    }
    
    private func doPostReport() {
        if self.isBusy() { return }
        Task.detached {
            await self.setUIForReporting(reporting: true, error: nil)
            let reported = await API.report(post_id: self.post.id)
            if reported {
                await self.setUIForReporting(reporting: false, error: false)
            } else {
                await self.setUIForReporting(reporting: false, error: true)
            }
        }
    }
    
    private func toggleLike(currentLiked: Bool) {
        Task.detached {
            var liked = currentLiked
            await self.setUIForLiking(isLiking: true, liked: liked)
            do {
                if let resp = try await API.like(post_id: self.post.id, status: !liked) {
                    liked = resp.likes
                }
            } catch {
                print(error)
            }
            await self.setUIForLiking(isLiking: false, liked: liked)
        }
    }
    
    private func _likeButtonImage() -> Image {
        if self.isLikedStatusLoading {
            return Image(systemName: "hourglass")
        }
        return Image(systemName: self.liked ? "heart.fill" : "heart")
    }
    
    @MainActor
    private func dismissSelf() async {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    @MainActor
    private func setUIForLiking(isLiking: Bool, liked: Bool) async {
        self.isLikedStatusSaving = isLiking
        self.liked = liked
    }
    
    @MainActor
    private func setUIForDeleting(deleting: Bool, error: Bool?) {
        self.isDeleting = deleting
        if let e = error {
            self.errorDeleting = e
        }
    }
    
    @MainActor
    private func setUIForReporting(reporting: Bool, error: Bool?) {
        self.isReporting = reporting
        if let e = error {
            self.errorReporting = e
            if !e {
                self.showReportSuccessfulToast = true
            }
        }
    }
    
    private func openURL() {
        if let product = getProductForPost(post: self.post) {
            if let validURL = URL(string: product.link) {
                UIApplication.shared.open(validURL, options: [:], completionHandler: nil)
            }
        }
    }
}
