//
//  FeedView.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import AlertToast
import Combine
import SwiftUI

struct FeedView: View {
    
    @EnvironmentObject var auth: AuthService
    
    @State var isFetching = false
    @State var currentPage: Int = 0
    @State var posts: [Post] = []
    
    @State var isProcessingCovetFollow: Bool = false
    
    let image3 = "https://cdn.motor1.com/images/mgl/QeWez9/s1/001.jpg"
    
    func _fetchNextPage() {
        Task {
            self.currentPage += 1;
            do {
                if let feedItems = try await API.getFeed(page: self.currentPage) {
                    for item in feedItems {
                        print("AN ITEM WAS")
                        print(item)
                        posts.append(item)
                    }
                } else {
                    throw RuntimeError("Unable to get feed items")
                }
            } catch {
                self.currentPage -= 1
            }
            self.isFetching = false
        }
    }
    
    var body: some View {
        
        // If the user just made their account, there will be no posts available AND
        // there will be no completed friend or follower requests yet
        if posts.count == 0 && auth.currentCovetUser?.isFollowingOrFriendingAnyone() == false {
            VStack {
                Spacer()
                Text("Looks like you're new!")
                    .font(.system(.headline))
                    .padding([.bottom], 8)
                    .padding([.leading, .trailing], 32)
                Text("Why don't you start seeing some products by following @Covet?")
                    .font(.system(.subheadline))
                    .padding([.bottom], 8)
                    .padding([.leading, .trailing], 32)
                    .multilineTextAlignment(.center)
                Button(action: {
                    if !self.isProcessingCovetFollow {
                        followCovet()
                    }
                }, label: {
                    Text("Follow @Covet")
                        .padding(.all, 8)
                        .foregroundColor(Color.white)
                })
                    .background(Color.covetGreen())
                    .cornerRadius(4)
                Spacer()
            }
            .toast(isPresenting: $isProcessingCovetFollow, alert: {
                AlertToast(displayMode: .alert, type: .loading, title: nil)
            })
        }
        
        // Otherwise, just show whatever we got..
        else {
            ScrollView {
                LazyVStack {
                    ForEach(self.posts) { post in
                        ZStack {
                            if let thumbnailImage = getThumbnailImageURLForPost(post: post), let user = post.user {
                                UserPreview(
                                    user: user,
                                    topItem: thumbnailImage
                                )
                                .onAppear(perform: {
                                    print("Running on appear")
                                    if let lastPost = $posts.last {
                                        if lastPost.wrappedValue.id == post.id {
                                            print("This is the last post (" + String(lastPost.wrappedValue.id) + " == " + String(post.id) + ")")
                                            if !self.isFetching {
                                                _fetchNextPage()
                                            }
                                        }
                                    }
                                })
                                .onTapGesture {
                                    
                                }
                            }
                        }
                    }
                }
            }
            .task {
                _fetchNextPage()
            }
        }
    }
    
    private func followCovet() {
        Task {
            self.isProcessingCovetFollow = true
            do {
                if let relationship = try await API.followCovet() {
                    await auth.refreshUser()
                }
            } catch {}
            self.isProcessingCovetFollow = false
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
