//
//  CovetUser.swift.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import Foundation

class CovetUser {
    
    static let mockedSample1 = CovetUser(uid: "amp-id-1")
    static let mockedSample2 = CovetUser(uid: "amp-id-2")
    
    private(set) var uid: String;
    
    init(uid: String) {
        self.uid = uid;
    }
    
}
