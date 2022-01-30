//
//  APIHelpers.swift
//  Covet
//
//  Created by Covet on 1/18/22.
//

import Alamofire
import Foundation

class APIHelpers {
        
    // headers: HTTPHeaders,
    
    static func getEndpointPromise<D: Decodable>(
        token: String?,
        endpoint: String,
        method: HTTPMethod,
        data: Parameters?,
        _ type: D.Type
    ) async throws -> D? {
        var res: D?;
        var errorMessage: String? = nil
        do {
            let semaphore = DispatchSemaphore (value: 0)
            let request = try await makeUrlRequest(endpoint: endpoint, method: method, data: data, token: token)
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
                    print("Error decoding")
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
    
    static func makeUrlRequest(endpoint: String, method: HTTPMethod, data: [String : Any]?, token: String?) async throws -> URLRequest {
        
        var requestUrlString = buildEndpointURL(
            endpoint: endpoint,
            data: method == .get ? data : nil
        )
        
        print(requestUrlString)
        
        var rq = URLRequest(url: URL(string: requestUrlString)!)
        rq.httpMethod = method == .post ? "POST" : "GET"
        rq.addValue("application/json", forHTTPHeaderField: "Content-Type")
        rq.addValue("application/json", forHTTPHeaderField: "Accept")
        if let tok = token {
            rq.addValue("Bearer " + tok, forHTTPHeaderField: "Authorization")
        }
        
        if let d = data {
            if method == .post {
                rq.httpBody = d.stringify().data(using: .utf8)
                print(d.stringify())
            }
        }
        
        return rq
    }
    
    static func buildEndpointURL(endpoint: String, data: [String : Any]?) -> String {
        if(!endpoint.starts(with: "/")) {
            return buildEndpointURL(endpoint: "/" + endpoint, data: data)
        }
        var url = APIConfig.hostname + endpoint
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
