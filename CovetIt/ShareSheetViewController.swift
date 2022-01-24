//
//  ShareSheetViewController.swift
//  CovetIt
//
//  Created by Covet on 1/23/22.
//

import UIKit
import Social
import MobileCoreServices
import Foundation
import UniformTypeIdentifiers

class ShareSheetViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getSharedURL { url in
            print("GOT THE URL")
            print(url)
        }
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
