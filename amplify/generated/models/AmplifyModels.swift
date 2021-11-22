// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "5118d20e2fd477c8c3ad5a23d3d12aef"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: UserRelationship.self)
    ModelRegistry.register(modelType: User.self)
    ModelRegistry.register(modelType: Covets.self)
    ModelRegistry.register(modelType: Product.self)
    ModelRegistry.register(modelType: ReportCovet.self)
    ModelRegistry.register(modelType: ReportUser.self)
  }
}