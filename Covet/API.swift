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

class API {
    private static let hostname: String = "http://localhost:3000/dev"
    
    public func getFeed(page: Int, completion: @escaping (_: [Post]) -> Void) async {
        getEndpoint(
            endpoint: "/feed/view",
            method: .get,
            headers: await getHeaders(),
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
            headers: await getHeaders(),
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
            headers: await getHeaders(),
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
            headers: await getHeaders(),
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
            headers: await getHeaders(),
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
            headers: await getHeaders(),
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
        AF.request(buildEndpointURL(endpoint: endpoint), method: method, parameters: data).responseData { response in
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
    
    private func getHeaders() async -> HTTPHeaders {
        if let token = await getIdToken() {
            return [.authorization(bearerToken: token)]
        }
        return []
    }
    
    private func getIdToken() async -> String? {
        if let currentUser = Auth.auth().currentUser {
            do {
                return await try currentUser.getIDToken()
            } catch {}
        }
        return nil
    }
    
    private func buildEndpointURL(endpoint: String) -> String {
        if(!endpoint.starts(with: "/")) {
            return buildEndpointURL(endpoint: "/" + endpoint)
        }
        return API.hostname + endpoint
    }
    
}
