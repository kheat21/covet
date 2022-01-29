//
//  APIStructs.swift
//  Covet
//
//  Created by Covet on 1/18/22.
//

import Foundation

struct CovetAPIError : Decodable {
    var message: String;
}

struct CovetAPIFailureResponse : Decodable {
    var error: CovetAPIError;
}
