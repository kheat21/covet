//
//  CovetUser.swift.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import Foundation

class CovetUser {
    
    static let mockedSample1 = CovetUser(amplifyUserId: "amp-id-1", username: "brendanmanning")
    static let mockedSample2 = CovetUser(amplifyUserId: "amp-id-2", username: "peytonmanning")
    
    private(set) var amplifyUserId: String;
    private(set) var username: String;
    
    init(amplifyUserId: String, username: String) {
        self.amplifyUserId = amplifyUserId;
        self.username = username;
    }
    
}
