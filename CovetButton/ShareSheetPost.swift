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
        guard let url = self.url?.absoluteString,
              let title = self.productTitle, !title.isEmpty,
              let image = self.image else {
            let alert = UIAlertController(title: "Missing Info", message: "Please make sure a product title and image are set before posting.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }

        Task {
            // Set the post button to a special state
            self.toggleButtonStatus(enabled: false)
            self.primaryButton?.setTitle("POSTING...", for: .normal)

            var createdPostSuccessfully = false
            do {
                if let _ = try await ExtensionAPI.createSingleProductPost(
                    url: url,
                    title: title,
                    image_url: image.getDatabaseValue(),
                    vendor: self.produtVendor,
                    price: self.productPrice,
                    caption: self.caption
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
                self.primaryButton?.setTitle("Send", for: .normal)
                
                let alert = UIAlertController(title: "Error Posting", message: "Please try again later", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
    }
}
