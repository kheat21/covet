// swiftlint:disable all
import Amplify
import Foundation

extension Product {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case type
    case link
    case image
    case covetsID
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let product = Product.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "Products"
    
    model.attributes(
      .index(fields: ["covetsID"], name: "byCovets")
    )
    
    model.fields(
      .id(),
      .field(product.type, is: .optional, ofType: .enum(type: ProductType.self)),
      .field(product.link, is: .optional, ofType: .string),
      .field(product.image, is: .optional, ofType: .string),
      .field(product.covetsID, is: .optional, ofType: .string),
      .field(product.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(product.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}