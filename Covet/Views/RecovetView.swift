//
//  RecovetView.swift
//  Covet
//
//  Created by Covet on 1/24/22.
//

import SwiftUI

struct RecovetView: View {
    
    @EnvironmentObject var auth: AuthService
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
                            .padding(EdgeInsets(top: 8, leading: 16,
                                                bottom: 8, trailing: 16))
                            //.background(Color.white)
                    }
                    
                    Spacer().frame(height: 40)
                }
                .shadow(color: Color.gray.opacity(0.4), radius: 3, x: 1, y: 2)
            }
            .navigationBarTitle("ReCovet it!")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button(
                    action: {
                        Task.detached {
                            await self.updateUI(saving: true, success: nil)
                            if let post = await self.doRecovet() {
                                await self.updateUI(saving: false, success: true)
                            } else {
                                await self.updateUI(saving: false, success: false)
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
    
    @MainActor
    private func updateUI(saving: Bool, success: Bool?) async {
        self.isSaving = saving
        if let successful = success {
            self.savedSuccessfully = successful
            if successful {
                await self.auth.refreshUser()
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
}

//struct RecovetView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecovetView()
//    }
//}
