// swiftlint:disable all
import Amplify
import Foundation

extension User {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case amplify_auth_id
    case covets
    case handle
    case name
    case bio
    case birthday
    case address
    case UserRelationships
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let user = User.keys
    
    model.authRules = [
      rule(allow: .private, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "Users"
    
    model.fields(
      .id(),
      .field(user.amplify_auth_id, is: .required, ofType: .string),
      .hasMany(user.covets, is: .optional, ofType: Covets.self, associatedWith: Covets.keys.userID),
      .field(user.handle, is: .required, ofType: .string),
      .field(user.name, is: .required, ofType: .string),
      .field(user.bio, is: .optional, ofType: .string),
      .field(user.birthday, is: .optional, ofType: .date),
      .field(user.address, is: .optional, ofType: .string),
      .hasMany(user.UserRelationships, is: .optional, ofType: UserRelationship.self, associatedWith: UserRelationship.keys.userID),
      .field(user.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(user.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}