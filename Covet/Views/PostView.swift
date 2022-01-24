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
    
    @State var post: Post
    
    @State var isLikedStatusLoading: Bool = true
    @State var isLikedStatusSaving: Bool = false
    @State var liked: Bool = false
    
    @State var showingShareActionSheet: Bool = false
    @State var showingAddressCopiedToast: Bool = false
    @State var showingNoAddressToCopyToast: Bool = false
    
    var body: some View {
        
        NavigationView {
            VStack {
                HStack {
                    Button {
                        if !self.isLikedStatusLoading && !self.isLikedStatusSaving {
                            Task { await self.toggleLike() }
                        }
                    } label: {
                        if self.isLikedStatusSaving {
                            ProgressView()
                        } else {
                            self._likeButtonImage()
                                .foregroundColor(
                                    self.isLikedStatusLoading
                                        ? Color.clear : Color.black
                                )
                        }
                    }
                    .padding([.leading], 125)
                    Button {
                        self.showingShareActionSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Color.black)
                    }
                    Button {
                        print("Recovet button was tapped")
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
                }
                .frame(width: nil, height: 40, alignment: Alignment.trailing)
                //.background(Color.cyan)
                if let product = getProductForPost(post: self.post) {
                    CovetSquareZoomedInItem(
                        url: product.image_url,
                        size: 250,
                        topBorderWidth: 4,
                        leftBorderWidth: 4,
                        bottomBorderWidth: 4,
                        rightBorderWidth: 4
                    )
                    .padding([.bottom], 16)
                    
                    if let productName = product.name {
                        Text(productName)
                            .font(.system(size: 24, weight: .regular, design: .default))
                    }
                    
                    HStack {
                        if let productVendor = product.vendor {
                            Text(productVendor)
                                .font(.system(size: 20, weight: .regular, design: .default))
                        }
                        if let productPrice = product.price {
                            Text("$" + String(productPrice))
                                .font(.system(size: 20, weight: .semibold, design: .default))
                        }
                    }
                    .padding([.top, .bottom], 8)
                    if let caption = self.post.text {
                        Text(caption)
                            .font(.system(size: 18, weight: .thin, design: .rounded))
                            .padding([.leading, .trailing], 16)
                    }
                }
                Spacer()
            }
            .toast(isPresenting: self.$showingAddressCopiedToast, duration: 2, tapToDismiss: true, alert: {
                AlertToast(displayMode: .banner(.pop), type: AlertToast.AlertType.complete(Color.covetGreen()), title: "Copied Address", subTitle: "Now use that to checkout on the merchant's website", style: nil)
            }, onTap: nil, completion: {
                if let product = getProductForPost(post: self.post) {
                    if let validURL = URL(string: product.link) {
                        UIApplication.shared.open(validURL, options: [:], completionHandler: nil)
                    }
                }
            })
            .toast(isPresenting: self.$showingNoAddressToCopyToast, duration: 2, tapToDismiss: true, alert: {
                AlertToast(displayMode: .banner(.pop), type: AlertToast.AlertType.complete(Color.red), title: "No address available", subTitle: "You'll have to ask your friend", style: nil)
            })
            .sheet(isPresented: $showingShareActionSheet) {
                PostShareSheet(activityItems: [
                    self.post.products![0].link
                ])
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CovetC(size: 36, text: "BM")
                }
                ToolbarItem(placement: .principal) {
                    Image("Covet_Logo_Colored")
                        .resizable()
                        .scaledToFit()
                        .frame(width: nil, height: 20, alignment: Alignment.center)
                }
            }
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
    
    private func toggleLike() async {
        
            do {
                self.isLikedStatusSaving = true
                if let resp = try await API.like(post_id: self.post.id, status: !self.liked) {
                    self.liked = resp.likes
                }
                self.isLikedStatusSaving = false
            } catch {
                print(error)
            }
        
    }
    
    private func _likeButtonImage() -> Image {
        if self.isLikedStatusLoading {
            return Image(systemName: "hourglass")
        }
        return Image(systemName: self.liked ? "heart.fill" : "heart")
    }
}
