// swiftlint:disable all
import Amplify
import Foundation

extension ReportCovet {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case complaint
    case covets
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let reportCovet = ReportCovet.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create])
    ]
    
    model.pluralName = "ReportCovets"
    
    model.fields(
      .id(),
      .field(reportCovet.complaint, is: .optional, ofType: .string),
      .belongsTo(reportCovet.covets, is: .optional, ofType: Covets.self, targetName: "reportCovetCovetsId"),
      .field(reportCovet.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(reportCovet.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}