//
//  CovetUser.swift.swift
//  Covet
//
//  Created by Brendan Manning on 11/22/21.
//

import Foundation
import Firebase

class CovetUser {
    
//    static let mockedSample1 = CovetUser(uid: "amp-id-1")
//    static let mockedSample2 = CovetUser(uid: "amp-id-2")
    
    private(set) var documentId: String;
    private(set) var uid: String;
    private(set) var name: String?;
    private(set) var handle: String?;
    private(set) var bio: String?;
    private(set) var birthday: Date?;
    private(set) var address: String?;
    
    private var following: Array<DocumentReference>?
    private var followers: Array<DocumentReference>?
    private var pendingIncomingFollowingRequests: Array<DocumentReference>?
    private var pendingOutgoingFollowingRequests: Array<DocumentReference>?
    private var friends: Array<DocumentReference>?
    private var pendingIncomingFriendRequests: Array<DocumentReference>?
    private var pendingOutgoingFriendRequests: Array<DocumentReference>?
    
    init(
        documentId: String, uid: String,
        name: String?, handle: String?,
        bio: String?, birthday: Date?, address: String?,
        following: Array<DocumentReference>?, followers: Array<DocumentReference>?,
        pendingIncomingFollowingRequests: Array<DocumentReference>?, pendingOutgoingFollowingRequests: Array<DocumentReference>?,
        friends: Array<DocumentReference>?,
        pendingIncomingFriendRequests: Array<DocumentReference>?, pendingOutgoingFriendRequests: Array<DocumentReference>?
    ) {
        self.documentId = documentId;
        self.uid = uid;
        self.name = name;
        self.handle = handle;
        self.bio = bio;
        self.birthday = birthday;
        self.address = address;
    }
    
    func isUserPrepared() -> Bool {
        return self.name != nil && self.handle != nil;
    }
    
    static func from(snapshot: QueryDocumentSnapshot) -> CovetUser? {
        print(snapshot.data())
        return CovetUser(
            documentId: snapshot.documentID,
            uid: snapshot.data()["uid"] as! String,
            name: snapshot.data()["name"] as? String,
            handle: snapshot.data()["handle"] as? String,
            bio: snapshot.data()["bio"] as? String,
            birthday: snapshot.data()["birthday"] as? Date,
            address: snapshot.data()["address"] as? String,
            following: snapshot.data()["following"] as? Array<DocumentReference>,
            followers: snapshot.data()["following"] as? Array<DocumentReference>,
            pendingIncomingFollowingRequests: snapshot.data()["pending_incoming_following_requests"] as? Array<DocumentReference>,
            pendingOutgoingFollowingRequests: snapshot.data()["pending_outgoing_following_requests"] as? Array<DocumentReference>,
            friends: snapshot.data()["friends"] as? Array<DocumentReference>,
            pendingIncomingFriendRequests: snapshot.data()["pending_incoming_friend_requests"] as? Array<DocumentReference>,
            pendingOutgoingFriendRequests: snapshot.data()["pending_outgoing_friend_requests"] as? Array<DocumentReference>
        )
    }
    
    static func search(firebaseUID: String) async -> Array<CovetUser>? {
        do {
            let documents = try await Firestore.firestore().collection("users").whereField("uid", isEqualTo: firebaseUID).getDocuments()
            return documents.documents.map { from(snapshot: $0) }.compactMap { $0 }
        } catch {
            return nil
        }
    }
    
}
