// swiftlint:disable all
import Amplify
import Foundation

public enum RelationshipStatus: String, EnumPersistable {
  case pending = "PENDING"
  case accepted = "ACCEPTED"
  case blocked = "BLOCKED"
}