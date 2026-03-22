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
    
    @State var isCoveted: Bool = false
    @State var isTogglingCoveted: Bool = false

    @State var isDeleting: Bool = false
    @State var errorDeleting: Bool = false
    @State var showingDeleteConfirmMessage: Bool = false
    
    func isBusy() -> Bool {
        return (
            self.isLikedStatusLoading ||
            self.isLikedStatusSaving ||
            self.isDeleting ||
            self.isTogglingCoveted
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Image with C. and ♡ overlaid on bottom-left
                if let product = getProductForPost(post: self.post) {
                    GeometryReader { geo in
                        ZStack(alignment: .bottomLeading) {
                            CovetSquareZoomedInItem(
                                url: product.image_url,
                                size: geo.size.width,
                                topBorderWidth: 0,
                                leftBorderWidth: 0,
                                bottomBorderWidth: 0,
                                rightBorderWidth: 0
                            )
                            .onTapGesture { self.openURL() }

                            // C. and ♡ overlay — bottom-left of image
                            HStack(spacing: 4) {
                                if !self.isOwnPost {
                                    Button {
                                        self.showingRecovetActionSheet = true
                                    } label: {
                                        Image("Recovet")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 44, height: 44)
                                    }
                                    .accessibilityLabel("Recovet")
                                }
                                Button {
                                    if !self.isBusy() { self.toggleLike(currentLiked: self.liked) }
                                } label: {
                                    if self.isLikedStatusSaving {
                                        ProgressView().frame(width: 36, height: 36)
                                    } else {
                                        self._likeButtonImage()
                                            .font(.system(size: 24))
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 1)
                                            .frame(width: 36, height: 36)
                                    }
                                }
                                .accessibilityLabel(liked ? "Unlike" : "Like")
                            }
                            .padding(10)
                        }
                    }
                    .aspectRatio(1, contentMode: .fit)

                    // Product info
                    let parsed = parseProductDisplay(name: product.name, vendor: product.vendor)
                    VStack(spacing: 4) {
                        if let brand = parsed.brand, !brand.isEmpty {
                            Text(brand.uppercased())
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.gray)
                                .tracking(0.5)
                        }
                        Text(parsed.cleanName)
                            .font(.system(size: 22, weight: .regular))
                            .multilineTextAlignment(.center)
                        if let priceStr = formatPrice(product.price) {
                            Text(priceStr)
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    .padding([.top, .bottom], 8)

                    if let caption = self.post.text {
                        Text(caption)
                            .lineLimit(5)
                            .font(.system(size: 18, weight: .thin, design: .rounded))
                            .padding(.horizontal, 16)
                    }
                }

                // Bottom row: own-post controls left, share right
                HStack {
                    if self.isOwnPost {
                        // Coveted
                        if self.isTogglingCoveted {
                            ProgressView().frame(width: 44, height: 44)
                        } else {
                            Button { self.toggleCoveted() } label: {
                                Image(systemName: isCoveted ? "checkmark.square.fill" : "square")
                                    .foregroundColor(Color.covetGreen())
                                    .font(.system(size: 22))
                                    .frame(width: 44, height: 44)
                            }
                            .accessibilityLabel(isCoveted ? "Mark as not coveted" : "Mark as coveted")
                        }
                        // Delete
                        if self.isDeleting {
                            ProgressView().frame(width: 44, height: 44)
                        } else {
                            Button { self.showingDeleteConfirmMessage = true } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(Color.red)
                                    .font(.system(size: 22))
                                    .frame(width: 44, height: 44)
                            }
                            .accessibilityLabel("Delete post")
                        }
                    }
                    Spacer()
                    // Share — bottom right
                    Button { self.showingShareActionSheet = true } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Color.covetGreen())
                            .font(.system(size: 22))
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Share")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                Spacer()
            }
        }
        .background(Color.covetGreen().opacity(0.05).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if let u = self.post.user {
                    NavigationLink(destination: ProfileView(userId: u.id)) {
                        makeCovetC(size: 36, user: u)
                    }
                } else {
                    EmptyView()
                }
            }
            ToolbarItem(placement: .principal) {
                Image("Covet_Logo_Colored")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)
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
        .sheet(isPresented: $showingShareActionSheet) {
            let deepLink = URL(string: "covet://post/\(post.user?.id ?? 0)/\(post.id)")!
            if let link = self.post.products?.first?.link, let productURL = URL(string: link) {
                PostShareSheet(activityItems: ["Check out this item on Covet!", deepLink, productURL])
            } else {
                PostShareSheet(activityItems: ["Check out this item on Covet!", deepLink])
            }
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
        .task {
            isCoveted = (post.coveted ?? 0) == 1
            do {
                if let likeStatus = try await API.likes(post_id: self.post.id) {
                    print(likeStatus)
                    self.liked = likeStatus.likes
                    self.isLikedStatusLoading = false
                }
            } catch {}
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
    
    private func toggleCoveted() {
        Task.detached {
            await MainActor.run { self.isTogglingCoveted = true }
            do {
                if let result = try await API.toggleCoveted(post_id: self.post.id) {
                    await MainActor.run {
                        self.isCoveted = result.coveted == 1
                        self.post.coveted = result.coveted
                    }
                }
            } catch { print(error) }
            await MainActor.run { self.isTogglingCoveted = false }
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
