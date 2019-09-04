//
//  Contact.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 2.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import Magpie
import CoreData

@objc(Contact)
public final class Contact: NSManagedObject, Model {
    @NSManaged public var identifier: String?
    @NSManaged public var address: String?
    @NSManaged public var image: Data?
    @NSManaged public var name: String?
    
    public required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Contact", in: managedObjectContext) else {
                fatalError("Failed to decode User")
        }
        
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decodeIfPresent(String.self, forKey: .identifier)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        self.image = try container.decodeIfPresent(Data.self, forKey: .image)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(identifier, forKey: .identifier)
        try container.encode(address, forKey: .address)
        try container.encode(image, forKey: .image)
        try container.encode(name, forKey: .name)
    }
    
    func encoded() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

extension Contact {
    enum CodingKeys: String, CodingKey {
        case identifier = "identifier"
        case address = "address"
        case image = "image"
        case name = "name"
    }
}

// MARK: Codable

extension Contact: Encodable {
}

extension Contact {
    
    static let entityName = "Contact"
}

// MARK: DBStorable

extension Contact: DBStorable {
}
