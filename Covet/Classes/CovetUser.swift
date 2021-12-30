//
//  CovetUser.swift.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import Foundation
import Firebase
import SwiftyJSON

class CovetUser: Identifiable {
    
    private(set) var id: Int;
    private(set) var authId: String;
    private(set) var username: String;
    private(set) var name: String?;
    private(set) var bio: String?;
    private(set) var birthday: Date?;
    private(set) var address: String?;
    
    private(set) var privateForFollowing: Bool;
    private(set) var privateForFriending: Bool;
    
    public func getDisplayItem() -> String {
        if let n = self.name {
            return n
        }
        return self.username
    }
    
    init(json: JSON) {
        self.id = json["id"].number!.intValue
        self.authId = json["authId"].string!
        self.username = json["username"].string!
        self.name = json["name"].string!
        self.bio = json["bio"].stringValue
        self.birthday = json["birthday"].stringValue.isoStringToDate()
        self.address = json["address"].stringValue
        self.privateForFollowing = json["privateForFollowing"].bool!
        self.privateForFriending = json["privateForFriending"].bool!
    }
    
    static func getSampleUser(number: Int, privateForFollowing: Bool, privateForFriending: Bool) -> CovetUser {
        let json: [String: Any] = [
            "id": 1,
            "authId": "google:" + String(number),
            "username": "user" + String(number),
            "name": "User #" + String(number),
            "bio": "Hello World " + String(number),
            "birthday": Date(timeIntervalSince1970: Double(number * 10000)),
            "address": String(number) + " Main St",
            "privateForFollowing": privateForFollowing,
            "privateForFriending": privateForFriending
        ]
        return CovetUser(json: JSON(json))
    }
}
 
