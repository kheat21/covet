//
//  ExtensionAPI.swift
//  Covet
//
//  Created by Covet on 1/18/22.
//

import Foundation
import Alamofire

class ExtensionAPI {
    
    public static func getImageURLs(
        url: String
    ) async -> [String]? {
        do {
            
            if let scraped_response = try await APIHelpers.getEndpointPromise(
                token: getToken(),
                endpoint: "/scrape",
                method: .get,
                data: [
                    "url": url
                ],
                ImageScrapeResponseObject.self,
                overrideBaseUrl: "https://ExpressLoadBalancer-380815732.us-east-1.elb.amazonaws.com:8000"
            ) {
                print(scraped_response.urls)
                return scraped_response.urls
            } else {
                print("invalid response")
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    public static func createSingleProductPost(
        url: String, title: String, image_url: String,
        vendor: String?, price: Double?, caption: String?
    ) async -> Post? {
        do {
            if let product = try await createProduct(url: url, title: title, image_url: image_url, vendor: vendor, price: price) {
                print(product)
                if let post = try await createPost(products: [product], caption: caption) {
                    return post
                } else {
                    throw RuntimeError("Could not create post")
                }
            } else {
                throw RuntimeError("Could not create product")
            }
        } catch {
            return nil
        }
    }
    
    public static func createProduct(
        url: String,
        title: String,
        image_url: String,
        vendor: String?,
        price: Double?
    ) async throws -> Product? {
        return try await APIHelpers.getEndpointPromise(
            token: getToken(),
            endpoint: "/product/create",
            method: .post,
            data: [
                "name": title,
                "link": url,
                "image_url": image_url,
                "vendor": vendor ?? nil,
                "price": price ?? nil
            ],
            Product.self,
            overrideBaseUrl: nil
        )
    }

    public static func createPost(
        products: [Product], caption: String?
    ) async throws -> Post? {
        return try await APIHelpers.getEndpointPromise(
            token: getToken(),
            endpoint: "/post/create",
            method: HTTPMethod.post,
            data: [
                "product_ids": products.map { p in
                    return p.id
                },
                "caption": caption
            ],
            Post.self,
            overrideBaseUrl: nil
        )
    }
    
    static func getToken() -> String? {
        var token: String? = nil
        if let components = ExtensionTokenService.getTokens() {
            print(components)
            token = "EXT:" + components.local + "/" + components.server + "/" + components.uid
        }
        print("token")
        print(token)
        return token
    }

}
