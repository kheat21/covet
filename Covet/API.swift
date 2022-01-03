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

class API {
    private static let hostname: String = "http://localhost:3000/dev"
    
    public static func createProfile(username: String, name: String?, birthday: Date?, address: String?) async throws -> CovetUser? {
        return try await getEndpointPromise(
            endpoint: "/user/relationships/create",
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
            data: [:],
            [CovetUserRelationship].self
        )
    }

    
    public func getFeed(page: Int, completion: @escaping (_: [Post]) -> Void) async {
        getEndpoint(
            endpoint: "/feed/view",
            method: .get,
            headers: await API.getHeaders(),
            data: [ "page": page ]
        ) { json in
            let feed = json["feed"].array
            completion(feed != nil ? feed!.map({ Post(json: $0) }) : [])
        }
    }
    public func getPost(products: [Product], text: String, completion: @escaping (_: Post?) -> Void) async {
        getEndpoint(
            endpoint: "/post/create",
            method: .post,
            headers: await API.getHeaders(),
            data: [
                "product_ids": products.map({ $0.id }),
                "text": text
            ]
        ) { json in
            completion(Post(json: json["post"]))
        }
    }
    public func getProduct(
        name: String,
        link: String,
        imageUrl: String,
        description: String,
        completion: @escaping (_: Product) -> Void
    ) async {
        getEndpoint(
            endpoint: "/product/create",
            method: .post,
            headers: await API.getHeaders(),
            data: [
                "name": name,
                "link": link,
                "image_url": imageUrl,
                "description": description
            ]
        ) { json in
            completion(Product(json: json["product"]))
        }
    }
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
    public func friendUser(
        userId: String,
        completion: @escaping (_: String?) -> Void
    ) async {
        getEndpoint(
            endpoint: "/user/friends/add",
            method: .post,
            headers: await API.getHeaders(),
            data: [
                "friend": userId
            ]
        ) { json in
            completion(json["status"].string)
        }
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
        AF.request(API.buildEndpointURL(endpoint: endpoint), method: method, parameters: data).responseData { response in
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
        data: Parameters,
        _ type: D.Type
    ) async throws -> D? {
        var res: D?;
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
                do {
                    res = try JSONDecoder().decode(type, from: data)
                } catch {}
                semaphore.signal()
            }
            
            task.resume()
            semaphore.wait()
        } catch {
            throw error
        }
        return res
    }
    
    static func makeUrlRequest(endpoint: String, method: HTTPMethod, data: [String : Any]) async throws -> URLRequest {
        let token = (await getIdToken())!
        var rq = URLRequest(url: URL(string: buildEndpointURL(endpoint: endpoint))!)
        rq.httpMethod = method == .post ? "POST" : "GET"
        rq.addValue("application/json", forHTTPHeaderField: "Content-Type")
        rq.addValue("application/json", forHTTPHeaderField: "Accept")
        rq.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        rq.httpBody = data.stringify().data(using: .utf8)
        
        
        print("Made request object")
        print(data.stringify())
        
        return rq
    }
    
    private static func getHeaders() async -> HTTPHeaders {
        if let token = await getIdToken() {
            return [.authorization(bearerToken: token)]
        }
        return []
    }
    
    private static func getIdToken() async -> String? {
        if let currentUser = Auth.auth().currentUser {
            do {
                return try await currentUser.getIDToken()
            } catch {}
        }
        return nil
    }
    
    private static func buildEndpointURL(endpoint: String) -> String {
        if(!endpoint.starts(with: "/")) {
            return buildEndpointURL(endpoint: "/" + endpoint)
        }
        return API.hostname + endpoint
    }
    
}
