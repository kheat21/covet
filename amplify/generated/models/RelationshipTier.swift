// swiftlint:disable all
import Amplify
import Foundation

public enum RelationshipTier: String, EnumPersistable {
  case following = "FOLLOWING"
  case friends = "FRIENDS"
}