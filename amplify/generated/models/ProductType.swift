// swiftlint:disable all
import Amplify
import Foundation

public enum ProductType: String, EnumPersistable {
  case link = "LINK"
  case image = "IMAGE"
}