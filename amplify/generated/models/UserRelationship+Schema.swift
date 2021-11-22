// swiftlint:disable all
import Amplify
import Foundation

extension UserRelationship {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case user
    case friend
    case tier
    case status
    case userID
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let userRelationship = UserRelationship.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "UserRelationships"
    
    model.attributes(
      .index(fields: ["userID"], name: "byUser")
    )
    
    model.fields(
      .id(),
      .belongsTo(userRelationship.user, is: .optional, ofType: User.self, targetName: "userRelationshipUserId"),
      .belongsTo(userRelationship.friend, is: .optional, ofType: User.self, targetName: "userRelationshipFriendId"),
      .field(userRelationship.tier, is: .optional, ofType: .enum(type: RelationshipTier.self)),
      .field(userRelationship.status, is: .optional, ofType: .enum(type: RelationshipStatus.self)),
      .field(userRelationship.userID, is: .optional, ofType: .string),
      .field(userRelationship.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(userRelationship.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}