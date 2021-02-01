//
//  Node.swift

import Foundation
import CoreData

@objc(Node)
public final class Node: NSManagedObject {
    @NSManaged public var address: String?
    @NSManaged public var token: String?
    @NSManaged public var name: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var creationDate: Date
}

extension Node {
    static let entityName = "Node"
}

extension Node {
    enum DBKeys: String {
        case address = "address"
        case token = "token"
        case name = "name"
        case isActive = "isActive"
        case creationDate = "creationDate"
    }
}

extension Node: DBStorable { }
