//
//  ShareViewController.swift
//  CovetIt
//
//  Created by Covet on 1/17/22.
//

import UIKit
import Social
import MobileCoreServices
import Foundation
import UniformTypeIdentifiers

// THANK: from https://github.com/scottfister/floop/blob/master/LICENSE

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        
        self.getSharedURL { url in
            print("Recieved")
            print(url)
            self.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)
        }
        
        // self.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)
    }
        
    func getSharedURL(completion: @escaping (_: NSURL?) -> Void) -> NSURL? {
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = item.attachments?.first {
                if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                
                    
                    itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, error) -> Void in
                        if let shareURL = url as? NSURL {
                            // do what you want to do with shareURL
                            completion(shareURL)
                        }
                        
                    })
                }
            }
        }
        return nil
    }
    
    // self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
}
