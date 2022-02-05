//
//  APIConfig.swift
//  Covet
//
//  Created by Covet on 1/18/22.
//

import Foundation

enum Stage {
    case LOCAL;
    case DEVELOP
    case STAGING;
    case PROD;
}

class APIConfig {
    
    static let stage: Stage = .PROD
    
    private static let local_serverless_hostname = "http://localhost:3000/dev"
    private static let staging_hostname = "https://og663wi5te.execute-api.us-east-1.amazonaws.com/staging"
    private static let prod_hostname = "https://pxsxnvvxej.execute-api.us-east-1.amazonaws.com/prod"
    
    static let hostname = getHostnameForStage(s: stage)
    
    private static func getHostnameForStage(s: Stage) -> String {
        switch(s) {
            case .LOCAL: return local_serverless_hostname
            case .DEVELOP: return "NO DEVELOP HOSTNAME YET"
            case .STAGING: return staging_hostname
            case .PROD: return prod_hostname
        }
    }
    
}
