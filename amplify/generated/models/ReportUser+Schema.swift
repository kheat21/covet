// swiftlint:disable all
import Amplify
import Foundation

extension ReportUser {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case User
    case complaint
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let reportUser = ReportUser.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create])
    ]
    
    model.pluralName = "ReportUsers"
    
    model.fields(
      .id(),
      .belongsTo(reportUser.User, is: .optional, ofType: UserRelationship.self, targetName: "reportUserUserId"),
      .field(reportUser.complaint, is: .optional, ofType: .string),
      .field(reportUser.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(reportUser.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}