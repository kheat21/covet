//
//  ShareSheetAlerts.swift
//  CovetIt
//
//  Created by Covet on 1/28/22.
//

import Foundation
import UIKit

extension ShareSheetViewController {

    func savePost() -> Void {
        Task {
            // Set the post button to a special state
            self.toggleButtonStatus(enabled: false)
            self.primaryButton?.setTitle("POSTING...", for: .normal)
            
            var createdPostSuccessfully = false
            do {
                if let createdPost = try await ExtensionAPI.createPost(
                    url: self.url!.absoluteString,
                    text: "Sample text",
                    productName: "Sample name",
                    productDescription: "Sample description",
                    imageURL: self.image!.url.absoluteString
                ) {
                    createdPostSuccessfully = true
                } else {
                    print("No error, but failed to decode the response")
                }
            } catch {
                print(error)
            }
            
            if createdPostSuccessfully {
                self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
            } else {
                self.toggleButtonStatus(enabled: true)
                self.primaryButton?.setTitle("POST", for: .normal)
                
                let alert = UIAlertController(title: "Error Posting", message: "Please try again later", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
    }
}
