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

    weak var config : SLComposeSheetConfigurationItem?

    var selectedImage: ScrapedImage?
    
    override var placeholder: String? {
        get { return "Say something about this product..." }
        set { }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView!.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func isContentValid() -> Bool {
        return self.selectedImage != nil && self.textView!.text!.count > 0
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
            let c = SLComposeSheetConfigurationItem()!
            c.title = "Image"
            c.value = self.selectedImage != nil ? "Selected" : "Pick one"
            c.tapHandler = { [unowned self] in
                let tvc = TableViewController(url: )
//                tvc.selectedSize = self.selectedText
//                tvc.delegate = self
                tvc.setSelectedImageHandler { image in
                    print("Selected image!! - " + image.url.absoluteString)
                    self.selectedImage = image
                    tvc.navigationController?.popViewController(animated: true)
                    self.reloadConfigurationItems()
                }
                self.pushConfigurationViewController(tvc)
            }
            self.config = c
            return [c]
    }
    
//    override func loadPreviewView() -> UIView! {
//        print("Called loadPreviewView()")
//        if let image = self.selectedImage {
//            return UIImageView(image: image.image)
//        } else {
//            return UIView()
//        }
//    }
    
}
