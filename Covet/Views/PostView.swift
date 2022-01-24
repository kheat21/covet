//
//  PostView.swift
//  Covet
//
//  Created by Covet on 1/24/22.
//

import Foundation
import SwiftUI

struct PostView: View {
    
    @State var post: Post
    
    @State var liked: Bool = false
    
    @State var showingShareActionSheet: Bool = false
    
    var body: some View {
        
        NavigationView {
            VStack {
                HStack {
                    Button {
                        print("Heart button was tapped")
                    } label: {
                        self._likeButtonImage().foregroundColor(Color.covetGreen())
                    }
                    .padding([.leading], 125)
                    Button {
                        self.showingShareActionSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Color.covetGreen())
                    }
                    Button {
                        print("Recovet button was tapped")
                    } label: {
                        Image("Recovet")
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
                    
                    Text("Nike Shoes")
                        .font(.system(size: 24, weight: .regular, design: .default))
                    Text("I really like these Nike shoes. They're super dope.")
                        .font(.system(size: 18, weight: .thin, design: .rounded))
                }
                Spacer()
            }
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
            
        }
    
    }
    
    private func toggleLikeState() {
        self.liked = !self.liked
        // Send this to the server
    }
    
    private func _likeButtonImage() -> Image {
        return Image(systemName: self.liked ? "heart.filled" : "heart")
    }
}
