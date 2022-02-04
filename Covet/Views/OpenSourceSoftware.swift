//
//  OpenSourceSoftware.swift
//  Covet
//
//  Created by Covet on 2/1/22.
//

import SwiftUI

enum License {
    case MIT
    case APACHE2
}

struct Attribution : Identifiable {
    
    internal var id: String
    var name: String;
    var link: String;
    var license: License;
    var licenseLink: String;
    
    init(name: String, link: String, license: License, licenseLink: String) {
        self.id = licenseLink
        self.name = name
        self.link = link
        self.license = license
        self.licenseLink = licenseLink
    }
    
    func getLicenseName() -> String {
        switch(self.license) {
        case .MIT: return "MIT"
        case .APACHE2: return "Apache 2.0"
        default: return "Unknown"
        }
    }
    
}

struct OpenSourceSoftware: View {
    
    private var attributions: [Attribution] = [
        Attribution(
            name: "Alamofire",
            link: "https://github.com/Alamofire/Alamofire/",
            license: .MIT,
            licenseLink: "https://github.com/Alamofire/Alamofire/blob/master/LICENSE"
        ),
        Attribution(
            name: "AlertToast",
            link: "https://github.com/elai950/AlertToast/",
            license: .MIT,
            licenseLink: "https://github.com/elai950/AlertToast/blob/master/LICENSE.md"
        ),
        Attribution(
            name: "FirebaseUI",
            link: "https://github.com/firebase/FirebaseUI-iOS/",
            license: .APACHE2,
            licenseLink: "https://github.com/firebase/FirebaseUI-iOS/blob/master/LICENSE"
        ),
        Attribution(
            name: "firebase-ios-sdk",
            link: "https://github.com/firebase/firebase-ios-sdk/",
            license: .APACHE2,
            licenseLink: "https://github.com/firebase/firebase-ios-sdk/blob/master/LICENSE"
        ),
        Attribution(
            name: "PromiseKit",
            link: "https://github.com/mxcl/PromiseKit",
            license: .MIT,
            licenseLink: "https://github.com/mxcl/PromiseKit/blob/v6/LICENSE"
        ),
        Attribution(
            name: "SwiftyJSON",
            link: "https://github.com/SwiftyJSON/SwiftyJSON/",
            license: .MIT,
            licenseLink: "https://github.com/SwiftyJSON/SwiftyJSON/blob/master/LICENSE"
        ),
        Attribution(
            name: "Socket.IO-Client-Swift",
            link: "https://github.com/socketio/socket.io-client-swift",
            license: .MIT,
            licenseLink: "https://github.com/socketio/socket.io-client-swift/blob/master/LICENSE"
        ),
        Attribution(
            name: "Kingfisher",
            link: "https://github.com/onevcat/Kingfisher",
            license: .MIT,
            licenseLink: "https://github.com/onevcat/Kingfisher/blob/master/LICENSE"
        )
    ]
    
    var body: some View {
        List {
            ForEach(attributions) { attribution in
                Button(action: {
                    if let validURL = URL(string: attribution.licenseLink) {
                        UIApplication.shared.open(validURL, options: [:], completionHandler: nil)
                    }
                }, label: {
                    Text(attribution.name)
                })
            }
        }
    }
}

struct OpenSourceSoftware_Previews: PreviewProvider {
    static var previews: some View {
        OpenSourceSoftware()
    }
}
