//
//  ImageScraper.swift
//  CovetIt
//
//  Created by Covet on 1/22/22.
//

import Foundation
import SocketIO
import SwiftSoup

struct ProductData {
    var title: String?
    var vendor: String?
    var price: String?
    var primaryImage: String?
    var allImages: [String]?
}

class ImageScraper {
    
    private var manager: SocketManager;
    private var socket: SocketIOClient;
    
    private var onConnectionCallback: ( () -> Void)?;
    private var onImageRecievedCallback: ( (_ image: ScrapedImage) -> Void)?;
    private var onBase64ImageRecievedCallback: ( (_ image: ScrapedImage) -> Void)?;
    private var onProductDataCallback: ((_ data: ProductData) -> Void)?;
    
    init() {
        self.manager = SocketManager(socketURL: URL(string: "http://covetimagescraperloadbalancer-830414987.us-east-1.elb.amazonaws.com:8000/")!, config: [
            .log(true)
        ])
        self.socket = manager.defaultSocket
    }
    
    func setOnConnected(callback: @escaping () -> Void) {
        self.onConnectionCallback = callback
    }
    
    func setOnImageRecieved(callback: @escaping (_ image: ScrapedImage) -> Void) {
        self.onImageRecievedCallback = callback
    }

    func setOnProductDataReceived(callback: @escaping (_ data: ProductData) -> Void) {
        self.onProductDataCallback = callback
    }
    
    func setup() {
        
        self.socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            if let callback = self.onConnectionCallback {
                callback()
            }
        }
        
        self.socket.on("product_data") { data, ack in
            guard let dict = data[0] as? [String: Any] else { return }
            let productData = ProductData(
                title: dict["title"] as? String,
                vendor: dict["vendor"] as? String,
                price: dict["price"] as? String,
                primaryImage: dict["primary_image"] as? String,
                allImages: dict["all_images"] as? [String]
            )
            self.onProductDataCallback?(productData)
        }

        self.socket.on("image") { data, ack in
            guard let url = data[0] as? String else {
                print("Something wrong with response recieved")
                return
            }
            print("Recieved: " + url)
            if let imgRecieved = self.onImageRecievedCallback {
                if let urlAsURL = URL(string: url) {
                    self.getUIImage(from: urlAsURL) { image in
                        if let img = image {
                            // if img.size.height >= 250 && img.size.width >= 250 {
                                imgRecieved(ScrapedImage(image: img, url: urlAsURL))
                            // }
                        }
                    }
                }
            }
        }
        
        /*
        self.socket.on("image_base64") { data, ack in
            guard let dataString = data[0] as? String else {
                print("Something went wrong with the 64 response recieved")
                return
            }
            if let imgRecieved = self.onBase64ImageRecievedCallback {
                if let data: Data = Data(base64Encoded: dataString, options: .ignoreUnknownCharacters) {
                    let decodedImage = UIImage(data: data)!
                    let scraped = ScrapedImage(image: decodedImage, url: nil, data: dataString)
                    imgRecieved(scraped)
                }
            }
        }
         */
    }
    
    func request(url: String) {
        print("Trying to send request to scrape " + url)
        self.socket.emit("/scrape", url) {
            print("Finished trying to emit the event")
        }
    }
    
    func connect() {
        self.socket.connect()
    }
    
    func disconnect() {
        self.socket.disconnect()
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
    
}
