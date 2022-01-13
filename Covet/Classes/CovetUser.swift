//
//  CovetUser.swift.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import Foundation
import Firebase
import SwiftyJSON
import PromiseKit

struct CovetUser: Identifiable, Decodable {

        var id: Int;
        var authId: String;
        var username: String;
        var name: String?;
        var bio: String?;
        var birthday: Date?;
        var address: String?;
        
        var privateForFollowing: Bool;
        var privateForFriending: Bool;
    
        var follows: [CovetUser]?
        var followers: [CovetUser]?
        var friends: [CovetUser]?
}
