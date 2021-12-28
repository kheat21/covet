//
//  UserListItem.swift
//  Covet
//
//  Created by Brendan Manning on 12/28/21.
//

import SwiftUI

struct UserListItem: View {
    
    @State var user: CovetUser;
    
    var body: some View {
        HStack {
            CovetC(size: 48)
            Text(user.getDisplayItem())
            Spacer()
            Chip(text: "FRIEND", color: Color.accentColor)
        }
    }
    
}
