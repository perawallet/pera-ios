//
//  ApplicationConfiguration.swift

import Foundation
import CoreData

@objc(ApplicationConfiguration)
public final class ApplicationConfiguration: NSManagedObject {
    @NSManaged public var password: String?
    @NSManaged public var authenticatedUserData: Data?
    @NSManaged public var isDefaultNodeActive: Bool
    
    func authenticatedUser() -> User? {
        guard let data = authenticatedUserData else {
            return nil
        }
        return try? JSONDecoder().decode(User.self, from: data)
    }
}

extension ApplicationConfiguration {
    enum DBKeys: String {
        case password = "password"
        case userData = "authenticatedUserData"
        case isDefaultNodeActive = "isDefaultNodeActive"
    }
}

extension ApplicationConfiguration {
    static let entityName = "ApplicationConfiguration"
}

extension ApplicationConfiguration: DBStorable { }
