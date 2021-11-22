// swiftlint:disable all
import Amplify
import Foundation

extension Covets {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case userID
    case Products
    case public_message
    case private_message
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let covets = Covets.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "Covets"
    
    model.attributes(
      .index(fields: ["userID"], name: "byUser")
    )
    
    model.fields(
      .id(),
      .field(covets.userID, is: .optional, ofType: .string),
      .hasMany(covets.Products, is: .optional, ofType: Product.self, associatedWith: Product.keys.covetsID),
      .field(covets.public_message, is: .optional, ofType: .string),
      .field(covets.private_message, is: .optional, ofType: .string),
      .field(covets.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(covets.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}