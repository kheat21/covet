//
//  CovetUserRelationship.swift
//  Covet
//
//  Created by Brendan Manning on 1/2/22.
//

import Foundation

enum CovetUserRelationshipType {
    case Following
    case Friends
    case Blocks
}

func userRelationshipTypeToString(rel: CovetUserRelationshipType) throws -> String {
    switch (rel) {
        case .Friends: return "befriend"
        case .Following: return "follow"
        case .Blocks: return "block"
        default: throw RuntimeError("CovetUserRelationshipType was invalid")
    }
}

class CovetUserRelationship : Decodable {
    private(set) var id: Int;
    private(set) var user: Int;
    private(set) var other: Int;
    private(set) var relationship: String;
    private(set) var pending: Bool;
}
