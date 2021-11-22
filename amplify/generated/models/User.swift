// swiftlint:disable all
import Amplify
import Foundation

public struct User: Model {
  public let id: String
  public var amplify_auth_id: String
  public var covets: List<Covets>?
  public var handle: String
  public var name: String
  public var bio: String?
  public var birthday: Temporal.Date?
  public var address: String?
  public var UserRelationships: List<UserRelationship>?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      amplify_auth_id: String,
      covets: List<Covets>? = [],
      handle: String,
      name: String,
      bio: String? = nil,
      birthday: Temporal.Date? = nil,
      address: String? = nil,
      UserRelationships: List<UserRelationship>? = []) {
    self.init(id: id,
      amplify_auth_id: amplify_auth_id,
      covets: covets,
      handle: handle,
      name: name,
      bio: bio,
      birthday: birthday,
      address: address,
      UserRelationships: UserRelationships,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      amplify_auth_id: String,
      covets: List<Covets>? = [],
      handle: String,
      name: String,
      bio: String? = nil,
      birthday: Temporal.Date? = nil,
      address: String? = nil,
      UserRelationships: List<UserRelationship>? = [],
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.amplify_auth_id = amplify_auth_id
      self.covets = covets
      self.handle = handle
      self.name = name
      self.bio = bio
      self.birthday = birthday
      self.address = address
      self.UserRelationships = UserRelationships
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}