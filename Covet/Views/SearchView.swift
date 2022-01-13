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
    
    // @ObservedObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            HStack {
                TextField("Search", text: $searchText, prompt: Text("A person, product, etc.."))
                Button("Search", action: {
                    Task {
                        print(try await API.search(query: searchText, page: 1))
                    }
                })
            }
            List {
                ForEach(searchResults, id: \.self) { name in
                    NavigationLink(destination: Text(name)) {
                        Text(name)
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
    
    var searchResults: [String] {
        if searchText.isEmpty {
            return []
        } else {
            return names.filter { $0.contains(searchText) }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
