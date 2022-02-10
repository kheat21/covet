//
//  ShareSheetThumbnails.swift
//  CovetIt
//
//  Created by Covet on 1/28/22.
//

import Foundation
import UIKit

extension ShareSheetViewController {
    
    /*
    func getImages(url: String) {
        Task.detached {
            if let urls = await ExtensionAPI.getImageURLs(url: url) {
                for url in urls {
                    if let urlAsURL = URL(string: url) {
                        await self.getUIImage(from: urlAsURL) { image in
                            if let img = image {
                                // if img.size.height >= 250 && img.size.width >= 250 {
                                Task.detached {
                                    await self.updateUI(newImage: ScrapedImage(image: img, url: urlAsURL, data: nil))
                                }
                                // }
                            }
                        }
                         
                    }
                }
            }
            
        }
    }
    
    @MainActor
    func updateUI(newImage: ScrapedImage) async {
        self.tableViewController.addImage(image: newImage)
    }
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    private func getUIImage(from url: URL, completion: @escaping (UIImage?) -> ()) {
        getData(from: url) { data, resp, err in
            if let d = data {
                completion(UIImage(data: d))
            }
        }
    }
    */
    
    func listedForScrapedImages(url: String) {

        let scraper: ImageScraper = ImageScraper()
        scraper.setup()

        scraper.setOnConnected {
            scraper.request(url: url)
        }

        scraper.setOnImageRecieved { image in
            self.tableViewController.addImage(image: image)
        }

        scraper.connect()

    }
    
}
