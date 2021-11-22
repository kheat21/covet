//
//  ContentViewDataModel.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import Foundation

class ContentViewDataModel: ObservableObject {
    @Published var amplify: AmplifyService = AmplifyService.shared
    @Published var auth: AuthService = AuthService.shared
}
