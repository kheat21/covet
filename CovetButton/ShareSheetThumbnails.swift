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

        scraper.setOnProductDataReceived { productData in
            DispatchQueue.main.async {
                self.applyProductData(productData)
            }
        }

        scraper.setOnImageRecieved { image in
            self.tableViewController.addImage(image: image)
        }

        scraper.connect()

    }

    func applyProductData(_ data: ProductData) {
        if let title = data.title { self.productTitle = title }
        if let vendor = data.vendor { self.produtVendor = vendor }
        if let priceStr = data.price, let priceDouble = Double(priceStr) {
            self.productPrice = priceDouble
        }

        // Refresh the current input field if it matches an auto-filled value
        if let field = self.inputFieldView {
            let stage = self.stages[self.stageIndex]
            switch stage {
            case .TITLE:
                field.text = self.productTitle
                self.toggleButtonStatus(enabled: self.productTitle != nil)
            case .VENDOR:
                field.text = self.produtVendor
                self.toggleButtonStatus(enabled: self.produtVendor != nil)
            case .PRICE:
                if let p = self.productPrice { field.text = String(p) }
                self.toggleButtonStatus(enabled: self.productPrice != nil)
            default: break
            }
        }

        // Auto-set the hero image from primary_image
        if let imageURLStr = data.primaryImage, let imageURL = URL(string: imageURLStr) {
            URLSession.shared.dataTask(with: imageURL) { imgData, _, _ in
                guard let d = imgData, let img = UIImage(data: d) else { return }
                DispatchQueue.main.async {
                    let scraped = ScrapedImage(image: img, url: imageURL)
                    self.image = scraped
                    self.imageView?.image = img
                    self.toggleImageBorderStatus(enabled: true)
                    if self.stages[self.stageIndex] == .PHOTO {
                        self.toggleButtonStatus(enabled: true)
                    }
                }
            }.resume()
        }
    }
    
}
