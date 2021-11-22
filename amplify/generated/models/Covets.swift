// swiftlint:disable all
import Amplify
import Foundation

public struct Covets: Model {
  public let id: String
  public var userID: String?
  public var Products: List<Product>?
  public var public_message: String?
  public var private_message: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      userID: String? = nil,
      Products: List<Product>? = [],
      public_message: String? = nil,
      private_message: String? = nil) {
    self.init(id: id,
      userID: userID,
      Products: Products,
      public_message: public_message,
      private_message: private_message,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      userID: String? = nil,
      Products: List<Product>? = [],
      public_message: String? = nil,
      private_message: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.userID = userID
      self.Products = Products
      self.public_message = public_message
      self.private_message = private_message
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}