//
//  RecovetView.swift
//  Covet
//
//  Created by Covet on 1/24/22.
//

import SwiftUI

struct RecovetView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    var post: Post;
    @State var caption: String = ""
    
    @State var isSaving: Bool = false
    @State var savedSuccessfully: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                Spacer().frame(height: 40)
                PostDisplay(post: self.post)
                ZStack {
                    if self.caption.count == 0 {
                        HStack {
                            Text("An optional caption here")
                                .font(.system(size: 18, weight: .thin, design: .default))
                                //.foregroundColor(Color.gray)
                                .padding([.leading, .top], 4)
                                //.background(Color.green)
                                .frame(width: nil, height: 128, alignment: .topLeading)
                                .multilineTextAlignment(.leading)
                                .allowsHitTesting(false)
                            Spacer()
                        }
                        .padding([.leading], 16)
                        .zIndex(2)
                        
                    }
                    HStack {
                        TextEditor(text: self.$caption)
                            .font(.system(size: 18, weight: .thin, design: .default))
                            //.frame(minWidth: 512, height: 128, alignment: .center)
                            .frame(width: nil, height: 128, alignment: Alignment.center)
                    }
                    .border(width: 1, edges: [.bottom, .top, .leading, .trailing], color: Color.covetGreen())
                    .padding([.leading, .trailing], 16)
                }
                
                
                
            }
            .navigationBarTitle("ReCovet it!")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button(
                    action: {
                        Task {
                            self.isSaving = true
                            if let post = await self.doRecovet() {
                                self.isSaving = false
                                self.savedSuccessfully = true
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                )
                {
                    if self.isSaving {
                        ProgressView()
                    } else {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(Color.covetGreen())
                    }
                }
            )
        }
    }
    
    private func doRecovet() async -> Post? {
        do {
            return try await API.recovet(post_id: self.post.id, caption: self.caption)
        } catch {
            return nil
        }
    }
    
}

//struct RecovetView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecovetView()
//    }
//}
