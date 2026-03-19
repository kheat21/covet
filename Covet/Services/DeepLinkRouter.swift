//
//  DeepLinkRouter.swift
//  Covet
//

import Foundation
import Combine

class DeepLinkRouter: ObservableObject {
    enum Destination {
        case profile(userId: Int)
        case post(userId: Int, postId: Int)
    }

    @Published var pending: Destination? = nil

    func handle(url: URL) {
        guard url.scheme == "covet" else { return }
        let parts = url.pathComponents.filter { $0 != "/" }
        switch url.host {
        case "profile":
            if let idStr = parts.first, let id = Int(idStr) {
                pending = .profile(userId: id)
            }
        case "post":
            if parts.count >= 2, let userId = Int(parts[0]), let postId = Int(parts[1]) {
                pending = .post(userId: userId, postId: postId)
            }
        default:
            break
        }
    }
}
