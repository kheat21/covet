//
//  CreatePostView.swift
//  Covet
//
//  Created by Brendan Manning on 12/27/21.
//

import Foundation
import SwiftUI

struct CreatePostView: View {
    
    @State var image: UIImage?;
    @State var isShowPhotoLibrary: Bool = false
    
    var body: some View {
        VStack {
            getImage(image: self.$image)
        }
        .sheet(isPresented: $isShowPhotoLibrary) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
        }
    }

}

func getImage(image: Binding<UIImage?>) -> AnyView {
    if let img = image.wrappedValue {
        return AnyView(
            Button(action: {}) {
                Image(uiImage: img)
            }
        )
    } else {
        return AnyView(
            Button("Pick an image", action: {
            
            })
        )
    }
}


/*
 .sheet(isPresented: $isShowPhotoLibrary) {
 ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
 }
 */
