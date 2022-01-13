//
//  FeedView.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import Combine
import SwiftUI

struct FeedView: View {
    
    @State var lastRecentFetchedPage: Int = 0
    @State var posts: [Post] = []
    
    let image1 = "https://hips.hearstapps.com/vader-prod.s3.amazonaws.com/1621545823-1e858398-6b43-4b4f-81bd-97d3679679dd_2.b511cad8f1874faa3a41d25d836758d6.jpg"
    
    let image2 = "https://n.nordstrommedia.com/id/sr3/92abe789-a05f-46a5-9af0-e7a949675482.jpeg?crop=pad&pad_color=FFF&format=jpeg&w=780&h=1196"
    
    let image3 = "https://cdn.motor1.com/images/mgl/QeWez9/s1/001.jpg"
    
    func _buildList() {
        return
    }
    
    func _fetchNextPage() {
        print("Fetching next page...")
    }
    
    var body: some View {
        ScrollView {
            ForEach(posts) { post in
                UserPreview(userAbbr: "BC", topItem: image3)
                    .onAppear(perform: {
                        if let lastPost = $posts.last {
                            if lastPost.wrappedValue.id == post.id {
                                _fetchNextPage()
                            }
                        }
                    })
            }
        }
        .task {
            do {
                if let returnedPosts = try await API.getFeed(page: 1) {
                    posts.append(contentsOf: returnedPosts)
                }
            } catch {
                print("Unable to fetch page 1")
            }
            
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
