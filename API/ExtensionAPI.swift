//
//  ExtensionAPI.swift
//  Covet
//
//  Created by Covet on 1/18/22.
//

import Foundation
import Alamofire

class ExtensionAPI {

    public static func createPost(
        url: String, text: String,
        productName: String, productDescription: String, imageURL: String
    ) async throws -> CreatePostResponse? {
        return try await APIHelpers.getEndpointPromise(
            token: getToken(),
            endpoint: "/post/create",
            method: HTTPMethod.post,
            data: [:],
            CreatePostResponse.self
        )
    }
    
    private static func getToken() -> String? {
        if let components = ExtensionTokenService.getTokens() {
            return "EXT:" + components.local + "/" + components.server + "/" + components.uid
        }
        return nil
    }

}
