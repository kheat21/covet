//
//  AppAPI.swift
//  Covet
//
//  Created by Covet on 1/18/22.
//

import Alamofire
import FirebaseAuth
import Foundation
import SwiftyJSON
import PromiseKit

class API {
    private static let hostname: String = "http://localhost:3000/dev"
    
    public static func setExtensionToken(localTokenComponent: String) async throws -> SetExtensionTokenResult? {
        return try await APIHelpers.getEndpointPromise(
            endpoint: "/user/extension_token/set",
            method: .post,
            headers: await getHeaders(),
            data: [
                "token": localTokenComponent
            ],
            SetExtensionTokenResult.self
        )
    }
    
    public static func me() async throws -> CovetUser? {
        return try await APIHelpers.getEndpointPromise(
            endpoint: "/user/profile/get",
            method: .get,
            headers: await getHeaders(),
            data: nil,
            CovetUser.self
        )
    }
    
    public static func createProfile(username: String, name: String?, birthday: Date?, address: String?) async throws -> CovetUser? {
        return try await APIHelpers.getEndpointPromise(
            endpoint: "/user/profile/create",
            method: .post,
            headers: await getHeaders(),
            data: [
                "username": username,
                "name": name ?? nil,
                "birthday": birthday?.formatted(),
                "address": address
            ],
            CovetUser.self
        )
    }
    
    public static func getRelationships() async throws -> [CovetUserRelationship]? {
        return try await APIHelpers.getEndpointPromise(
            endpoint: "/user/relationships/list",
            method: .get,
            headers: await getHeaders(),
            data: nil,
            [CovetUserRelationship].self
        )
    }

    
    public static func getFeed(page: Int) async throws -> [Post]? {
        print("Getting feed...")
        let resp = try await APIHelpers.getEndpointPromise(
            endpoint: "/feed/view",
            method: .get,
            headers: await getHeaders(),
            data: [ "page": String(page) ],
            [ Post ].self
        )
        print(resp)
        return resp
    }
    
    public static func search(query: String, page: Int, pageSize: Int = 50) async throws -> UnifiedSearchResult? {
        return try await APIHelpers.getEndpointPromise(
            endpoint: "/search/search",
            method: .get,
            headers: await getHeaders(),
            data: [
                "query": query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
                "page": String(page),
                "pageSize": String(pageSize)
            ],
            UnifiedSearchResult.self
        )
    }
    
    private func setBlockedStatusForUser(
        userId: String,
        blockedStatus: Bool,
        completion: @escaping (_: String?) -> Void
    ) async {
        APIHelpers.getEndpoint(
            endpoint: "/user/block/block",
            method: .post,
            headers: await API.getHeaders(),
            data: [
                "block": userId,
                "status": blockedStatus
            ]
        ) { json in
            completion(json["blocked"].string)
        }
    }
    public func blockUser(userId: String, completion: @escaping (_: String?) -> Void) async {
        await setBlockedStatusForUser(userId: userId, blockedStatus: true, completion: completion)
    }
    public func unblockUser(userId: String, completion: @escaping (_: String?) -> Void) async {
        await setBlockedStatusForUser(userId: userId, blockedStatus: false, completion: completion)
    }
    
    
    
    public static func setRelationship(userId: Int, relationshipType: CovetUserRelationshipType) async throws -> SetUserRelationshipResponseObject? {
        return try await APIHelpers.getEndpointPromise(
            endpoint: "/user/relationships/set",
            method: .post,
            headers: await API.getHeaders(),
            data: [
                "user": userId,
                "relationship_type": userRelationshipTypeToString(rel: relationshipType)
            ],
            SetUserRelationshipResponseObject.self
        )
    }
    
    public func followUser(
        userId: String,
        completion: @escaping (_: String?) -> Void
    ) async {
        APIHelpers.getEndpoint(
            endpoint: "/user/following/add",
            method: .post,
            headers: await API.getHeaders(),
            data: [
                "following": userId
            ]
        ) { json in
            completion(json["status"].string)
        }
    }
    
    private static func getHeaders() async -> HTTPHeaders {
        if let token = await getIdToken() {
            return [.authorization(bearerToken: token)]
        }
        return []
    }
    
    static func getIdToken() async -> String? {
        if let currentUser = Auth.auth().currentUser {
            do {
                return try await currentUser.getIDToken()
            } catch {}
        }
        return nil
    }
    
}
