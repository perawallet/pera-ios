//
//  Node.swift
//  algorand
//
//  Created by Omer Emre Aslan on 10.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Foundation
import CoreData

@objc(Node)
public final class Node: NSManagedObject {
    enum DBKeys: String {
        case address = "address"
        case token = "token"
        case name = "name"
        case isActive = "isActive"
        case creationDate = "creationDate"
    }
    
    @NSManaged public var address: String?
    @NSManaged public var token: String?
    @NSManaged public var name: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var creationDate: Date
}

extension Node {
    static let entityName = "Node"
}

extension Node: DBStorable {
}
