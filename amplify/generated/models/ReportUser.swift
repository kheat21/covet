// swiftlint:disable all
import Amplify
import Foundation

public struct ReportUser: Model {
  public let id: String
  public var User: UserRelationship?
  public var complaint: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      User: UserRelationship? = nil,
      complaint: String? = nil) {
    self.init(id: id,
      User: User,
      complaint: complaint,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      User: UserRelationship? = nil,
      complaint: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.User = User
      self.complaint = complaint
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}