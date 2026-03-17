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

    public let verified: Int?;
    public let deleted: Int?;
    public let removed: Int?;
    public let category: String?;

//    public let createdAt: Date;
//    public let lastUpdatedAt: Date;
}

// Ordered by priority: more specific categories first to avoid false matches
// (e.g. "top handle bag" should match Accessories before Clothing's "top")
private let categoryKeywords: [(String, [String])] = [
    ("Shoes", ["shoe", "boot", "sneaker", "heel", "sandal", "loafer", "slipper", "flat", "pump", "mule", "clog", "oxford", "trainer", "footwear", "stiletto", "wedge", "espadrille"]),
    ("Accessories", ["bag", "handbag", "purse", "wallet", "belt", "hat", "cap", "scarf", "glove", "sunglasses", "glasses", "watch", "jewelry", "necklace", "earring", "bracelet", "ring", "keychain", "backpack", "clutch", "tote", "luggage", "suitcase", "umbrella", "tie", "bow tie"]),
    ("Beauty", ["lipstick", "mascara", "foundation", "concealer", "blush", "eyeshadow", "serum", "moisturizer", "lotion", "cream", "perfume", "cologne", "fragrance", "shampoo", "conditioner", "skincare", "makeup", "beauty", "nail", "polish", "toner", "cleanser", "sunscreen", "spf", "hair", "brush", "palette"]),
    ("Tech", ["phone", "case", "charger", "cable", "earbuds", "headphones", "speaker", "laptop", "tablet", "camera", "lens", "tripod", "keyboard", "mouse", "monitor", "tech", "electronic", "gadget", "smart", "wireless", "bluetooth", "usb", "adapter", "stand"]),
    ("Home", ["candle", "pillow", "blanket", "throw", "rug", "lamp", "vase", "frame", "mug", "plate", "bowl", "kitchen", "home", "decor", "furniture", "chair", "table", "shelf", "curtain", "towel", "bedding", "sheet", "duvet", "coaster", "tray", "mirror", "art", "print", "poster"]),
    ("Clothing", ["shirt", "dress", "jacket", "coat", "pants", "jeans", "shorts", "skirt", "sweater", "hoodie", "blouse", "top", "cardigan", "blazer", "suit", "tee", "sweatshirt", "leggings", "denim", "pullover", "vest", "tank", "bikini", "swimsuit", "pajama", "lingerie", "underwear", "bra", "apparel", "clothing", "wear"]),
]

func guessCategory(for product: Product) -> String {
    if let cat = product.category, !cat.isEmpty { return cat }
    let text = ((product.name) + " " + (product.vendor ?? "") + " " + (product.description ?? "")).lowercased()
    for (category, keywords) in categoryKeywords {
        if keywords.contains(where: { keyword in
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
            let range = text.range(of: pattern, options: .regularExpression)
            return range != nil
        }) {
            return category
        }
    }
    return "All"
}
