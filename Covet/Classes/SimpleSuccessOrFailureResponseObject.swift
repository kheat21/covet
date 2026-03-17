//
//  SimpleSuccessOrFailureResponseObject.swift
//  Covet
//
//  Created by Covet on 2/2/22.
//

import Foundation

struct SimpleSuccessOrFailureResponseObject : Decodable {
    var success: Bool;
}

struct ToggleCovetiResponseObject : Decodable {
    var success: Bool;
    var coveted: Int;
}

struct GiftIdeaResponse: Decodable {
    var name: String
    var reason: String
    var price_range: String
    var search_query: String
    var shop_url: String?
}

struct GiftRecommendationsResponseObject: Decodable {
    var ideas: [GiftIdeaResponse]
    var styleSummary: String?

    enum CodingKeys: String, CodingKey {
        case ideas
        case styleSummary
    }
}
