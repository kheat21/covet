// swiftlint:disable all
import Amplify
import Foundation

public struct Product: Model {
  public let id: String
  public var type: ProductType?
  public var link: String?
  public var image: String?
  public var covetsID: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      type: ProductType? = nil,
      link: String? = nil,
      image: String? = nil,
      covetsID: String? = nil) {
    self.init(id: id,
      type: type,
      link: link,
      image: image,
      covetsID: covetsID,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      type: ProductType? = nil,
      link: String? = nil,
      image: String? = nil,
      covetsID: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.type = type
      self.link = link
      self.image = image
      self.covetsID = covetsID
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}