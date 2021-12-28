//
//  CovetUser.swift.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import Foundation
import Firebase

class CovetUser: Identifiable {
    
    private(set) var uid: String;
    private(set) var name: String?;
    private(set) var handle: String?;
    private(set) var bio: String?;
    private(set) var birthday: Date?;
    private(set) var address: String?;
    
    public func getDisplayItem() -> String {
        if let n = self.name {
            return n
        }
        if let h = self.handle {
            return h
        }
        return "Unknown"
    }
    
    init(uid: String) {
        self.uid = uid;
        self.name = "Brendan Manning"
        self.handle = "brendanmanning"
        self.bio = "My name is Brendan Manning"
    }
    
}
