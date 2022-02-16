//
//  SearchView.swift
//  Covet
//
//  Created by Brendan Manning on 11/29/21.
//

import SwiftUI
import AlertToast

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
    
    @State var isSearching: Bool = false;
    @State var error: Bool = false;
    
//    @State private var navigateToUserView: Bool = false
    @State private var navigateToPost: Post? = nil
        
    private var gridItems = [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer().frame(width: 8)
                    TextField("Search", text: $searchText, prompt: Text("A person, product, etc.."))
                        .padding(7)
                        .padding(.horizontal, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal, 10)
                    Button("Search", action: {
                        if !self.isSearching {
                            KeyboardHelper.hideKeyboard()
                            doSearch(query: searchText)
                        }
                    })
                    Spacer().frame(width: 16)
                    
                }
                Spacer()
                if let results = _results {
                    ScrollView {
                        
                        // Show the users first
                        if results.users.count > 0 {
                            UserLongPressHelpNudge()
                                .padding(.bottom, 8)
                        }
                        ForEach(results.users.prefix(5)) { user in
//                            NavigationLink {
//                                ProfileView(userId: user.id)
//                            } label: {
                                UserListItem(
                                    user: user //,
                                    // clickable: shouldAllowClicksForUser(user: user)
                                )
//                                .foregroundColor(Color.black)
//                            }
                        }
                    
                        // Show the posts next
                        if let posts = results.posts {
                            ImageGrid(images: results.posts, selected: { p in
                                print("selected " + String(p.id))
                                self.navigateToPost = p
                            })
                        }
                    }
                    
                }
                
            
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toast(isPresenting: $isSearching, alert: {
                AlertToast(displayMode: .alert, type: .loading)
            })
            .toast(isPresenting: $error) {
                AlertToast(displayMode: .hud, type: .error(Color.red), title: "Search failed", subTitle: "Try again")
            }
            .sheet(item: self.$navigateToPost, onDismiss: nil) { item in
                PostView(post: item)
            }
        }
    }
    
    func doSearch(query: String) -> Void {
        self.isSearching = true
        Task.detached {
            let results = try await API.search(query: query, page: 1)
            await self.updateUI(results: results)
            
            if let r = results {
                let p = r.posts
                for post in p {
                    print(post.id)
                }
                
            }
        }
    }
    
    @MainActor
    func updateUI(results: UnifiedSearchResult?) {
        self._results = results
        self.isSearching = false
        self.error = results == nil
    }
    
    func getImageForPost(post: Post) -> String {
        return post.products![0].image_url
    }

}

//
//struct SearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        Sear
//    }
//}

