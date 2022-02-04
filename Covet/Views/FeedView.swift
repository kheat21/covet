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
    
    @State var isRefreshingTop = false
    @State var isFetching = false
    @State var currentPage: Int = 1
    @State var posts: [Post]? = nil
    
//    @State var openUser: CovetUser? = nil
    
    let image3 = "https://cdn.motor1.com/images/mgl/QeWez9/s1/001.jpg"
    
    func _fetchFirstPage() {
        _fetchNextPage(clearBeforeUpdating: true)
    }
    
    func _fetchNextPage(clearBeforeUpdating: Bool = false) {
        self.isFetching = true
        if clearBeforeUpdating {
            self.currentPage = 1
        }
        Task.detached {
            var items: [Post]? = nil
            do {
                items = try await API.getFeed(page: self.currentPage)
            } catch {}
            await self.updateUI(clear: clearBeforeUpdating, newItems: items)
        }
    }
    
    func updateUI(clear: Bool, newItems: [Post]?) {
        if let items = newItems {
            if self.posts == nil || clear {
                self.posts = []
            }
            for item in items {
                posts!.append(item)
            }
            if items.count > 0 {
                self.currentPage += 1;
            }
        }
        self.isFetching = false
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // If the user just made their account, there will be no posts available AND
            // there will be no completed friend or follower requests yet
            if let user = auth.currentCovetUser, let posts = self.posts {
                
                if posts.count == 0 && user.isFollowingOrFriendingAnyone() == false {
                    FollowCovetView()
                }
                            
                // Otherwise, just show whatever we got..
                else {
                    List {
                        ForEach(Array(posts.enumerated()), id: \.offset) { index, post in
                            ZStack {
                                if let thumbnailImage = getThumbnailImageURLForPost(post: post), let user = post.user {
                                    HStack {
                                        Spacer()
                                        UserPreview(
                                            user: user,
                                            topItem: thumbnailImage
                                        )
                                        NavigationLink {
                                            ProfileView(isLoggedInUser: false, otherUser: user)
                                                .navigationBarTitle(user.username)
                                        } label: {
                                            
                                        }
                                        .padding([.top], 8)
                                        .padding([.bottom], 8)
                                        .buttonStyle(PlainButtonStyle()).frame(width:0).opacity(0)
                                        Spacer()
                                    }
                                    .onAppear(perform: {
                                        print("Running on appear")
                                        if let lastPost = posts.last {
                                            if lastPost.id == post.id {
                                                print("This is the last post (" + String(lastPost.id) + " == " + String(post.id) + ")")
                                                if !self.isFetching {
                                                    _fetchNextPage()
                                                }
                                            }
                                        }
                                    })
//                                    .onTapGesture {
//                                        self.openUser = user
//                                    }
                                }
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                    .padding(.top, 0)
                    .listStyle(PlainListStyle())
                    .refreshable {
                        Task.detached {
                            await self._fetchFirstPage()
                        }
                    }
                }
            }
        }
        .toast(isPresenting: $isFetching, alert: {
            AlertToast(displayMode: .alert, type: .loading, title: nil)
        })
//        .sheet(item: $openUser, onDismiss: nil, content: { item in
//            ProfileView(isLoggedInUser: false, otherUser: item)
//        })
        .task {
            _fetchFirstPage()
        }
    }
}
