//
//  ExtensionAPI.swift
//  Covet
//
//  Created by Covet on 1/18/22.
//

import Foundation
import Alamofire

class ExtensionAPI {

    public static func setExtensionToken(localTokenComponent: String) async throws -> SetExtensionTokenResult? {
        return try await APIHelpers.getEndpointPromise(
            token: nil,
            endpoint: "/user/extension_token/set",
            method: .post,
            data: [
                "token": localTokenComponent
            ],
            SetExtensionTokenResult.self
        )
    }
    
    private static func getHeaders() async -> HTTPHeaders {
//        if let token = await () {
//            return [.authorization(bearerToken: token)]
//        }
        return []
    }

}
