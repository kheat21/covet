//
//  ShareSheetThumbnails.swift
//  CovetIt
//

import Foundation
import UIKit

extension ShareSheetViewController {

    func listedForScrapedImages(url: String) {
        let scraper = ImageScraper()
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

    func applyExtensionScrape(_ data: ExtensionScrapedProduct) {
        if let title = data.title, !title.isEmpty {
            productTitle = title
            itemNameFieldView?.text = title
        }
        if let vendor = data.vendor, !vendor.isEmpty {
            produtVendor = vendor
            brandFieldView?.text = vendor
        }
        if let priceStr = data.price, let priceDouble = Double(priceStr), priceDouble > 0 {
            productPrice = priceDouble
            priceLabelView?.text = "$\(Int(priceDouble))"
            priceLabelView?.textColor = UIColor.label
        }
        // Load og:image if no image selected yet
        if image == nil, let imageURLStr = data.imageURL, let imageURL = URL(string: imageURLStr) {
            URLSession.shared.dataTask(with: imageURL) { imgData, _, _ in
                guard let d = imgData, let img = UIImage(data: d) else { return }
                DispatchQueue.main.async {
                    self.image = ScrapedImage(image: img, url: imageURL)
                    self.imageView?.image = img
                    self.imageView?.layer.borderWidth = 2
                }
            }.resume()
        }
    }

    func applyProductData(_ data: ProductData) {
        // Fill in stored values
        if let title = data.title, !title.isEmpty {
            productTitle = title
            itemNameFieldView?.text = title
        }
        if let vendor = data.vendor, !vendor.isEmpty {
            produtVendor = vendor
            brandFieldView?.text = vendor
        }
        if let priceStr = data.price, let priceDouble = Double(priceStr), priceDouble > 0 {
            productPrice = priceDouble
            priceLabelView?.text = "$\(Int(priceDouble))"
            priceLabelView?.textColor = .label
        }

        // Auto-set hero image from primary_image
        if let imageURLStr = data.primaryImage, let imageURL = URL(string: imageURLStr) {
            URLSession.shared.dataTask(with: imageURL) { imgData, _, _ in
                guard let d = imgData, let img = UIImage(data: d) else { return }
                DispatchQueue.main.async {
                    let scraped = ScrapedImage(image: img, url: imageURL)
                    self.image = scraped
                    self.imageView?.image = img
                    self.imageView?.layer.borderWidth = 2
                }
            }.resume()
        }
    }
}
