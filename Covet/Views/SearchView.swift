//
//  SearchView.swift
//  Covet
//
//  Created by Brendan Manning on 11/29/21.
//

import SwiftUI

import Combine

// https://stackoverflow.com/a/66186680
/*
final class ViewModel: ObservableObject {
    private var disposeBag = Set<AnyCancellable>()

    @Published var text: String = ""

    init() {
        self.debounceTextChanges()
    }

    private func debounceTextChanges() {
        $text
            // 2 second debounce
            .debounce(for: 1, scheduler: RunLoop.main)
        
            .

            // Called after 2 seconds when text stops updating (stoped typing)
            .sink {
                print("new text value: \($0)")
                
                await API.search(query: <#T##String#>, page: <#T##Int#>)
                
                
            }
            .store(in: &disposeBag)
    }
}
*/

struct SearchView: View {
    let names = ["Holly", "Josh", "Rhonda", "Ted"]
    @State private var searchText = ""
    
    @State private var _results: UnifiedSearchResult? = nil;
    
    // @ObservedObject var viewModel = ViewModel()
    
    private var gridItems = [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)]
    
    var body: some View {
        NavigationView {
            VStack {
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
                    //
                        ForEach(results.users.prefix(5)) { user in
                            UserListItem(user: user)
                        }
                    
                    
                        // Show the posts next
                        if let posts = results.posts {
                            ImageGrid(images: results.posts.map { $0
                                return getImageForPost(post: $0)
                            })
                        }
                    }
                    
                }
                
            
            }
//            .searchable(text: $viewModel.text) {
//                ForEach(searchResults, id: \.self) { result in
//                    Text("Are you looking for \(result)?").searchCompletion(result)
//                }
//            }
            .navigationTitle("Friends")
            
        }
    }
    
    func getImageForPost(post: Post) -> String {
        return post.products[0].image_url
    }
    
    var searchResults: [String] {
        if searchText.isEmpty {
            return []
        } else {
            return names.filter { $0.contains(searchText) }
        }
    }
    
    func getTopBorderWidth(index: Int) -> CGFloat {
        return 4;
    }
    
    func getBottomBorderWidth(index: Int, total: Int) -> CGFloat {
        return index >= total - 3 ? 4 : 0;
    }
    
    func getLeftBorderWidth(index: Int) -> CGFloat {
        return 4;
    }
    
    func getRightBorderWidth(index: Int, total: Int) -> CGFloat {
        return (index % 3 == 2 || index == total - 1) ? 4 : 0;
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

