// swiftlint:disable all
import Amplify
import Foundation

public struct ReportCovet: Model {
  public let id: String
  public var complaint: String?
  public var covets: Covets?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      complaint: String? = nil,
      covets: Covets? = nil) {
    self.init(id: id,
      complaint: complaint,
      covets: covets,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      complaint: String? = nil,
      covets: Covets? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.complaint = complaint
      self.covets = covets
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}