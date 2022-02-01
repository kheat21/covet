//
//  HamburgerOptionsView.swift
//  Covet
//
//  Created by Covet on 1/31/22.
//

import SwiftUI

struct HamburgerOptionsView: View {
    var body: some View {
        List {
            Text("Manage my account")
            Text("Delete my account")
            Text("Logout")
            Text("Open Source Software")
        }
    }
}

struct HamburgerOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        HamburgerOptionsView()
    }
}
