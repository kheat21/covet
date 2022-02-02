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
    
    public static func me() async throws -> CovetUserResponseObject? {
        return try await API.getUser(user_id: nil)
    }
    
    public static func getUser(user_id: Int?) async throws -> CovetUserResponseObject? {
        let resp = try await APIHelpers.getEndpointPromise(
            token: await getIdToken(),
            endpoint: "/user/profile/get",
            method: HTTPMethod.get,
            //headers: await getHeaders(),
            data: user_id != nil ? [
                "user": user_id
            ] : nil,
            CovetUserResponseObject.self
        )
        print(resp)
        return resp
    }
    
    public static func createProfile(
        username: String, name: String?, birthday: Date?, address: String?,
        privateForFollowing: Int, privateForFriending: Int
    ) async throws -> CovetUser? {
        return try await APIHelpers.getEndpointPromise(
            token: await getIdToken(),
            endpoint: "/user/profile/create",
            method: HTTPMethod.post,
            //headers: await getHeaders(),
            data: [
                "username": username,
                "name": name ?? nil,
                "birthday": birthday?.formatted(),
                "address": address,
                "privateForFollowing": privateForFollowing,
                "privateForFriending": privateForFriending
            ],
            CovetUser.self
        )
    }
    
    public static func updateProfile(
        originalUser: CovetUser,
        name: String?, bio: String?, birthday: Date?, address: String?,
        privateForFollowing: Int?, privateForFriending: Int?
    ) async throws -> CovetUser? {
        return try await APIHelpers.getEndpointPromise(
            token: await getIdToken(),
            endpoint: "/user/profile/update",
            method: HTTPMethod.post,
            data: [
                "user": originalUser.id,
                "name": name ?? originalUser.name ?? "",
                "bio": bio ?? originalUser.bio ?? "",
                "birthday": birthday?.formatted() ?? nil,
                "address": address ?? originalUser.address ?? "",
                "privateForFollowing": privateForFollowing ?? originalUser.privateForFollowing,
                "privateForFriending": privateForFriending ?? originalUser.privateForFriending
            ],
            CovetUser.self
        )
    }
    
    public static func getRelationships() async throws -> [CovetUserRelationship]? {
        return try await APIHelpers.getEndpointPromise(
            token: await getIdToken(),
            endpoint: "/user/relationships/list",
            method: HTTPMethod.get,
            // headers: await getHeaders(),
            data: nil,
            [CovetUserRelationship].self
        )
    }

    
    public static func getFeed(page: Int) async throws -> [Post]? {
        print("Getting feed...")
        let resp = try await APIHelpers.getEndpointPromise(
            token: await getIdToken(),
            endpoint: "/feed/view",
            method: HTTPMethod.get,
            // headers: await getHeaders(),
            data: [ "page": String(page) ],
            [ Post ].self
        )
        print(resp)
        return resp
    }
    
    public static func search(query: String, page: Int, pageSize: Int = 50) async throws -> UnifiedSearchResult? {
        return try await APIHelpers.getEndpointPromise(
            token: await getIdToken(),
            endpoint: "/search/search",
            method: HTTPMethod.get,
            // headers: await getHeaders(),
            data: [
                "query": query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
                "page": String(page),
                "pageSize": String(pageSize)
            ],
            UnifiedSearchResult.self
        )
    }
    
    public static func likes(post_id: Int) async throws -> IsLikedResponseObject? {
        return try await APIHelpers.getEndpointPromise(
            token: await getIdToken(),
            endpoint: "/post/is_liked",
            method: .get,
            data: [
                "post_id": String(post_id)
            ],
            IsLikedResponseObject.self
        )
    }
    
    public static func like(post_id: Int, status: Bool) async throws -> IsLikedResponseObject? {
        print("Trying to like record...")
        return try await APIHelpers.getEndpointPromise(
            token: await getIdToken(),
            endpoint: "/post/like",
            method: .post,
            data: [
                "post_id": String(post_id),
                "status": status ? "like" : "unlike"
            ],
            IsLikedResponseObject.self
        )
    }
    
    public static func recovet(post_id: Int, caption: String) async throws -> Post? {
        return try await APIHelpers.getEndpointPromise(
            token: await getIdToken(),
            endpoint: "/post/recovet",
            method: .post,
            data: [
                "post_id": String(post_id),
                "text": caption.count > 0 ? caption : nil
            ],
            Post.self
        )
    }
    
    /*
    private func setBlockedStatusForUser(
        userId: String,
        blockedStatus: Bool,
        completion: @escaping (_: String?) -> Void
    ) async {
        APIHelpers.getEndpoint(
            token: await getIdToken(),
            endpoint: "/user/block/block",
            method: HTTPMethod.post,
            // headers: await API.getHeaders(),
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
     */
    
    public static func setRelationship(userId: Int, relationshipType: CovetUserRelationshipType) async throws -> SetUserRelationshipResponseObject? {
        return try await APIHelpers.getEndpointPromise(
            token: await getIdToken(),
            endpoint: "/user/relationships/set",
            method: .post,
            // headers: await API.getHeaders(),
            data: [
                "user": userId,
                "relationship_type": userRelationshipTypeToString(rel: relationshipType)
            ],
            SetUserRelationshipResponseObject.self
        )
    }
    
    /*
    public func followUser(
        userId: String,
        completion: @escaping (_: String?) -> Void
    ) async {
        APIHelpers.getEndpoint(
            endpoint: "/user/following/add",
            method: HTTPMethod.post,
            // headers: await API.getHeaders(),
            data: [
                "following": userId
            ]
        ) { json in
            completion(json["status"].string)
        }
    }
    */
    
    private static func getHeaders() async -> HTTPHeaders {
        if let token = await getIdToken() {
            return [.authorization(bearerToken: token)]
        }
        return []
    }

    static func getIdToken() async -> String? {
        if let currentUser = Auth.auth().currentUser {
            do {
                let token = try await currentUser.getIDToken()
                print(token)
                return token
            } catch {}
        }
        return nil
    }
    
}
