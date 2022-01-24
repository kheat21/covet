//
//  Product.swift
//  Covet
//
//  Created by Brendan Manning on 12/27/21.
//

import Foundation
import SwiftyJSON

struct Product: Decodable {
    
    public let id: Int;
    public let initial_creator: CovetUser;
    
    public let name: String;
    public let description: String?;
    
    public let link: String;
    public let image_url: String;
    
    public let vendor: String?;
    public let price: Double?;
    
    public let verified: Bool?;
    
    public let deleted: Int?;
    public let removed: Int?;
    
//    public let createdAt: Date;
//    public let lastUpdatedAt: Date;
}
