//
//  Post.swift
//  Covet
//
//  Created by Brendan Manning on 12/27/21.
//

import Foundation
import SwiftyJSON

struct Post : Identifiable, Decodable {
    var id: Int;
    var user: CovetUser?;
    var text: String?;
    //var name: String?;
    var products: [Product]?;
    var deleted: Int?;
    var removed: Int?;
    var createdAt: Int;
    
    var highlighted_product_id: Int?;
}

func getProductForPost(post: Post) -> Product? {
    if let products = post.products {
        if let id = post.highlighted_product_id {
            return products.filter { product in
                return product.id == id
            }[0]
        } else {
            return products[0]
        }
    }
    return nil
}
