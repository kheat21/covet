// swiftlint:disable all
import Amplify
import Foundation

public struct UserRelationship: Model {
  public let id: String
  public var user: User?
  public var friend: User?
  public var tier: RelationshipTier?
  public var status: RelationshipStatus?
  public var userID: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      user: User? = nil,
      friend: User? = nil,
      tier: RelationshipTier? = nil,
      status: RelationshipStatus? = nil,
      userID: String? = nil) {
    self.init(id: id,
      user: user,
      friend: friend,
      tier: tier,
      status: status,
      userID: userID,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      user: User? = nil,
      friend: User? = nil,
      tier: RelationshipTier? = nil,
      status: RelationshipStatus? = nil,
      userID: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.user = user
      self.friend = friend
      self.tier = tier
      self.status = status
      self.userID = userID
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}