//
//  SearchView.swift
//  Covet
//
//  Created by Brendan Manning on 11/29/21.
//

import SwiftUI

struct SearchView: View {
//
//    private var shouldShowSavingToast: Binding<Bool>
//    private var shouldShowErrorToast: Binding<Bool>
//    private var errorToastContents: Binding<String>
//
//    init(
//        shouldShowSavingToast: Binding<Bool>,
//        shouldShowErrorToast: Binding<Bool>,
//        errorToastContents: Binding<String>
//    ) {
//        self.shouldShowSavingToast = shouldShowSavingToast
//        self.shouldShowErrorToast = shouldShowErrorToast
//        self.errorToastContents = errorToastContents
//    }
    
    @State var searchText: String = ""
    @State var _results: UnifiedSearchResult? = nil;
    
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
                    Spacer().frame(width: 8)
                    TextField("Search", text: $searchText, prompt: Text("A person, product, etc.."))
                        .padding(7)
                        .padding(.horizontal, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal, 10)
                    Button("Search", action: {
                        Task {
                            _results = try await API.search(query: searchText, page: 1)
                        }
                    })
                    Spacer().frame(width: 16)
                    
                }
                Spacer()
                if let results = _results {
                    ScrollView {
                        
                        // Show the users first
                        ForEach(results.users.prefix(5)) { user in
                            UserListItem(
                                user: user,
                                clickable: shouldAllowClicksForUser(user: user)
                            )
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
            .navigationTitle("Search")
        }
    }
    
    func getImageForPost(post: Post) -> String {
        return post.products![0].image_url
    }
    
    func shouldAllowClicksForUser(user: CovetUser) -> Bool {
        // Allow clicks on completely public profiles
        if user.privateForFollowing == 0 && user.privateForFriending == 0 {
            return true
        }
        
        // Otherwise, check if we have a relationship with them
        if user.allRelationshipInformationPresent() {
            return user.currentUserFollows() || user.currentUserFriend()
        }
        return false
    }

}

//
//struct SearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        Sear
//    }
//}

