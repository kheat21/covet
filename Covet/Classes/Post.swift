//
//  Post.swift
//  Covet
//
//  Created by Brendan Manning on 12/27/21.
//

import Foundation
import SwiftyJSON

class Post: Identifiable, Decodable {
    private(set) var id: Int;
    private(set) var user: CovetUser;
    private(set) var text: String;
    private(set) var name: String;
    private(set) var products: [Product];
    private(set) var deleted: Int;
    private(set) var removed: Int;
    private(set) var createdAt: Int;
    init(json: JSON) {
        self.id = json["id"].int!
        self.user = CovetUser(json: json["user"])
        self.text = json["text"].string!
        self.name = json["name"].string!
        self.products = json["products"].array!.map({ p in
            return Product(json: p)
        })
        self.deleted = json["deleted"].int!
        self.removed = json["removed"].int!
        self.createdAt = json["createdAt"].int!
    }
}
