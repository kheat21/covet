//
//  Product.swift
//  Covet
//
//  Created by Brendan Manning on 12/27/21.
//

import Foundation
import SwiftyJSON

class Product {
    
    public let id: Int;
    public let initial_creator: CovetUser;
    
    public let name: String;
    public let description: String?;
    
    public let link: String;
    public let image_url: String;
    
    public let vendor: String?;
    public let verified: Bool;
    
    public let deleted: Bool;
    public let removed: Bool;
    
    public let createdAt: Date;
    public let lastUpdatedAt: Date;
    
    init(json: JSON) {
        self.id = 0
        self.initial_creator = CovetUser.getSampleUser(number: 1, privateForFollowing: true, privateForFriending: true)
        self.name = ""
        self.description = ""
        self.link = ""
        self.image_url = ""
        self.vendor = ""
        self.verified = false
        self.deleted = false
        self.removed = false
        self.createdAt = Date()
        self.lastUpdatedAt = Date()
    }
    
}
