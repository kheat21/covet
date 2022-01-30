//
//  FeedView.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import Combine
import SwiftUI

struct FeedView: View {
    
    @State var isFetching = false
    @State var currentPage: Int = 0
    @State var posts: [Post] = []
    
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
        ScrollView {
            LazyVStack {
                ForEach(posts) { post in
                    if let thumbnailImage = getThumbnailImageURLForPost(post: post) {
                        UserPreview(
                            userAbbr: "BC",
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
                    }
                }
            }
        }
        .task {
            _fetchNextPage()
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
