//
//  SearchView.swift
//  Covet
//
//  Created by Brendan Manning on 11/29/21.
//

import SwiftUI

struct SearchView: View {
    let names = ["Holly", "Josh", "Rhonda", "Ted"]
    @State private var searchText = ""
    
    @State private var _results: UnifiedSearchResult? = nil;
    
//    @State private var navigateToUserView: Bool = false
//    @State private var navigateToUserId: Int = -1
        
    private var gridItems = [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)]
    
    var body: some View {
        NavigationView {
            VStack {
//                NavigationLink(isActive: self.$navigateToUserView, destination: {
//                    ProfileView(id: self.navigateToUserId)
//                }, label: {
//                    EmptyView()
//                })
                HStack {
                    TextField("Search", text: $searchText, prompt: Text("A person, product, etc.."))
                    Button("Search", action: {
                        Task {
                            _results = try await API.search(query: searchText, page: 1)
                        }
                    })
                    
                }
                Spacer()
                if let results = _results {
                    ScrollView {
                        
                        // Show the users first
                        ForEach(results.users.prefix(5)) { user in
                            UserListItem(user: user)
//                                .onTapGesture {
//                                    self.navigateToUserId = user.id
//                                    self.navigateToUserView = true
//                                }
                        }
                    
                        // Show the posts next
                        if let posts = results.posts {
                            ImageGrid(images: results.posts, selected: { i in
                                print(i)
                            })
                        }
                    }
                    
                }
                
            
            }
            .navigationTitle("Friends")
        }
    }
    
    func getImageForPost(post: Post) -> String {
        return post.products![0].image_url
    }

}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

