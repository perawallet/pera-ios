//
//  ApplicationConfiguration.swift
//  algorand
//
//  Created by Omer Emre Aslan on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation
import CoreData

@objc(ApplicationConfiguration)
public final class ApplicationConfiguration: NSManagedObject {
    enum DBKeys: String {
        case password = "password"
        case userData = "authenticatedUserData"
    }
    
    @NSManaged public var password: String?
    @NSManaged public var authenticatedUserData: Data?
    
    func authenticatedUser() -> User? {
        guard let data = authenticatedUserData else {
            return nil
        }
        
        return try? JSONDecoder().decode(User.self, from: data)
    }
}

extension ApplicationConfiguration {
    static let entityName = "ApplicationConfiguration"
}

extension ApplicationConfiguration: DBStorable {
}
