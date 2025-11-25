// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ContactsManager.swift

import pera_wallet_core

// FIXME: Replace it with a micro-service
enum ContactsManager {
    
    enum ContactsManagerError: Error {
        case contactNotFound
        case unableToFetch(error: DBOperationError)
        case unableToCreateContact(error: DataBaseStoreError)
        case unableToUpdateContact(error: DataBaseStoreError)
    }
    
    static func createContact(name: String, address: String) throws(ContactsManagerError) -> Contact {
        
        let contact: Contact
        
        do {
            contact = try Contact.create()
        } catch {
            throw .unableToCreateContact(error: error)
        }
        
        return try update(contact: contact, name: name, address: address)
    }
    
    static func updateContact(name: String, address: String) throws(ContactsManagerError) -> Contact {
        
        let predicate: NSPredicate = NSPredicate(format: "address == %@", address)
        let result = Contact.fetchAllSyncronous(entity: Contact.entityName, with: predicate)
        let contact: Contact?
        
        switch result {
        case let .result(object):
            contact = object as? Contact
        case let .results(objects):
            contact = objects.first as? Contact
        case let .error(error):
            throw .unableToFetch(error: error)
        }
        
        guard let contact else { throw .contactNotFound }
        return try update(contact: contact, name: name, address: address)
    }
    
    private static func update(contact: Contact, name: String, address: String) throws(ContactsManagerError) -> Contact {
        do {
            contact.name = name
            contact.address = address
            try Contact.save()
            return contact
        } catch {
            throw .unableToUpdateContact(error: error)
        }
    }
}
