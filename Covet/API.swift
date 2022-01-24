//
//  API.swift
//  Covet
//
//  Created by Brendan Manning on 12/27/21.
//

import Alamofire
import FirebaseAuth
import Foundation
import SwiftyJSON
import PromiseKit

struct CovetAPIError : Decodable {
    var message: String;
}

struct CovetAPIFailureResponse : Decodable {
    var error: CovetAPIError;
}

class API {
    private static let hostname: String = "http://localhost:3000/dev"
    
    public static func me() async throws -> CovetUser? {
        return try await getEndpointPromise(
            endpoint: "/user/profile/get",
            method: .get,
            headers: await getHeaders(),
            data: nil,
            CovetUser.self
        )
    }
    
    public static func createProfile(username: String, name: String?, birthday: Date?, address: String?) async throws -> CovetUser? {
        return try await getEndpointPromise(
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
        return try await getEndpointPromise(
            endpoint: "/user/relationships/list",
            method: .get,
            headers: await getHeaders(),
            data: nil,
            [CovetUserRelationship].self
        )
    }

    
    public static func getFeed(page: Int) async throws -> [Post]? {
        print("Getting feed...")
        let resp = try await getEndpointPromise(
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
        return try await getEndpointPromise(
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
    
    public static func likes(post_id: Int) async throws -> IsLikedResponseObject? {
        return try await getEndpointPromise(
            endpoint: "/post/is_liked",
            method: .get,
            headers: await getHeaders(),
            data: [
                "post_id": String(post_id)
            ],
            IsLikedResponseObject.self
        )
    }
    
    public static func like(post_id: Int, status: Bool) async throws -> IsLikedResponseObject? {
        print("Trying to like record...")
        return try await getEndpointPromise(
            endpoint: "/post/like",
            method: .post,
            headers: await getHeaders(),
            data: [
                "post_id": String(post_id),
                "status": status ? "like" : "unlike"
            ],
            IsLikedResponseObject.self
        )
    }
    
    public static func recovet(post_id: Int, caption: String) async throws -> Post? {
        return try await getEndpointPromise(
            endpoint: "/post/recovet",
            method: .post,
            headers: await getHeaders(),
            data: [
                "post_id": String(post_id),
                "text": caption.count > 0 ? caption : nil
            ],
            Post.self
        )
    }
    
//    public func getPost(products: [Product], text: String, completion: @escaping (_: Post?) -> Void) async {
//        getEndpoint(
//            endpoint: "/post/create",
//            method: .post,
//            headers: await API.getHeaders(),
//            data: [
//                "product_ids": products.map({ $0.id }),
//                "text": text
//            ]
//        ) { json in
//            completion(Post(json: json["post"]))
//        }
//    }
    
//    public func getProduct(
//        name: String,
//        link: String,
//        imageUrl: String,
//        description: String,
//        completion: @escaping (_: Product) -> Void
//    ) async {
//        getEndpoint(
//            endpoint: "/product/create",
//            method: .post,
//            headers: await API.getHeaders(),
//            data: [
//                "name": name,
//                "link": link,
//                "image_url": imageUrl,
//                "description": description
//            ]
//        ) { json in
//            completion(Product(json: json["product"]))
//        }
//    }
    private func setBlockedStatusForUser(
        userId: String,
        blockedStatus: Bool,
        completion: @escaping (_: String?) -> Void
    ) async {
        getEndpoint(
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
        return try await getEndpointPromise(
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
        getEndpoint(
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

    
    private func getEndpoint(
        endpoint: String,
        method: HTTPMethod,
        headers: HTTPHeaders,
        data: Parameters,
        completion: @escaping (_: JSON) -> Void
    ) {
        AF.request(API.buildEndpointURL(endpoint: endpoint, data: data), method: method, parameters: data).responseData { response in
            do {
                if let status = response.response?.statusCode {
                    debugPrint("Response: \(response)")
                    let json = JSON(try response.result.get())
                    completion(json)
                }
            } catch {}
        }
        
        /*
        AF.request(buildEndpointURL(endpoint: endpoint), method: method, parameters: data).responseDecodable { response: DataResponse<Decodable, AFError> in
    
                //to get status code
                if let status = response.response?.statusCode {
                    switch(status){
                    case 200:
                        
                        if((response.result.value) != nil) {
                            
                            let swiftyJsonVar = JSON(response.result.value!)
                            print(swiftyJsonVar)
                        }
                    
                    default:
                        print("error with response status: \(status)")
                    }
                }
        }
         */
    }

    private static func getEndpointPromise<D: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        headers: HTTPHeaders,
        data: Parameters?,
        _ type: D.Type
    ) async throws -> D? {
        var res: D?;
        var errorMessage: String? = nil
        do {
            let semaphore = DispatchSemaphore (value: 0)
            let request = try await makeUrlRequest(endpoint: endpoint, method: method, data: data)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    print(String(describing: error))
                    semaphore.signal()
                    return
                }
                print(String(data: data, encoding: .utf8)!)
                
                // Try to decode as an unsuccessful response
                do {
                    let errorRes = try JSONDecoder().decode(CovetAPIFailureResponse.self, from: data)
                    errorMessage = errorRes.error.message
                } catch {}
                
                // Try to decode as a successful response
                do {
                    res = try JSONDecoder().decode(type, from: data)
                    print(res)
                } catch {
                    print(error)
                }
                semaphore.signal()
            }
            
            task.resume()
            semaphore.wait()
        } catch {
            throw error
        }
        
        if let msg = errorMessage {
            throw RuntimeError(msg)
        }
        
        return res
    }
    
    static func makeUrlRequest(endpoint: String, method: HTTPMethod, data: [String : Any]?) async throws -> URLRequest {
        let token = (await getIdToken())!
        var rq = URLRequest(url:
            URL(string: buildEndpointURL(
                endpoint: endpoint,
                data: method == .get ? data : nil
            ))!
        )
        rq.httpMethod = method == .post ? "POST" : "GET"
        rq.addValue("application/json", forHTTPHeaderField: "Content-Type")
        rq.addValue("application/json", forHTTPHeaderField: "Accept")
        rq.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        
        if let d = data {
            if method == .post {
                rq.httpBody = d.stringify().data(using: .utf8)
                print(d.stringify())
            }
        }
        
        print(rq.url)
        
        return rq
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
    
    private static func buildEndpointURL(endpoint: String, data: [String : Any]?) -> String {
        if(!endpoint.starts(with: "/")) {
            return buildEndpointURL(endpoint: "/" + endpoint, data: data)
        }
        var url = API.hostname + endpoint
        if let d = data {
            var components = URLComponents()
            components.queryItems = d.map {
                URLQueryItem(name: $0, value: $1 as? String)
            }
            print(components.query)
            
            url += "?" + components.query!
        }
        return url
    }
    
}
