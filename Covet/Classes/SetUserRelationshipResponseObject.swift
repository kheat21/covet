//
//  SetUserRelationshipResponseObject.swift
//  Covet
//
//  Created by Covet on 1/16/22.
//

import Foundation

struct SetUserRelationshipResponseObject : Decodable {
    var madeRelationship: CovetUserRelationship
    var otherUser: CovetUser
}
