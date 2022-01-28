//
//  ShareSheetThumbnails.swift
//  CovetIt
//
//  Created by Covet on 1/28/22.
//

import Foundation

extension ShareSheetViewController {
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
