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

class CovetUserRelationship : Decodable {
    private(set) var user: CovetUser;
    private(set) var other: CovetUser;
    private(set) var relationship: String;
    private(set) var pending: Bool;
}
