//
//  DBStorable.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 3.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import CoreData
import UIKit

enum DBOperationError: Error {
    case readFailed
    case writeFailed
    case noContext
}

enum DBOperationResult<Object: DBStorable> {
    case result(object: NSManagedObject)
    case results(objects: [Any])
    case error(error: DBOperationError)
}

protocol DBStorable: AnyObject {
    
    typealias DBOperationHandler = (DBOperationResult<Self>) -> Void
    typealias DBOperationErrorHandler = (DBOperationError?) -> Void
    
    static func create(entity: String, with keyedValues: [String: Any], then handler: DBOperationHandler?)
    static func fetchAll(entity: String, with predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?, then handler: DBOperationHandler?)
    static func clear(entity: String)
    
    func update(entity: String, with keyedValues: [String: Any], then handler: DBOperationHandler?)
    func remove(entity: String, then handler: DBOperationHandler?)
}

extension DBStorable where Self: NSManagedObject {
    
    static func create(entity: String, with keyedValues: [String: Any], then handler: DBOperationHandler? = nil) {
        guard let appDelegate = UIApplication.shared.appDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: entity, in: context) else {
            handler?(.error(error: .noContext))
            return
        }
        
        let object = NSManagedObject(entity: entity, insertInto: context)
        
        object.setValuesForKeys(keyedValues)
        
        do {
            try context.save()
            
            handler?(.result(object: object))
        } catch {
            handler?(.error(error: .writeFailed))
        }
    }
    
    static func fetchAll(entity: String,
                         with predicate: NSPredicate? = nil,
                         sortDescriptor: NSSortDescriptor? = nil,
                         then handler: DBOperationHandler? = nil) {
        guard let appDelegate = UIApplication.shared.appDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        if let sortDescriptor = sortDescriptor {
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        
        do {
            let response = try context.fetch(fetchRequest)
            
            handler?(.results(objects: response))
        } catch {
            handler?(.error(error: .readFailed))
        }
    }
    
    static func fetchAllSyncronous(entity: String,
                                   with predicate: NSPredicate? = nil,
                                   sortDescriptor: NSSortDescriptor? = nil) -> DBOperationResult<Self> {
        
        guard let appDelegate = UIApplication.shared.appDelegate else {
            return .error(error: .noContext)
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        if let sortDescriptor = sortDescriptor {
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        
        do {
            let response = try context.fetch(fetchRequest)
            
            return .results(objects: response)
        } catch {
            return .error(error: .readFailed)
        }
    }
    
    static func clear(entity: String) {
        guard let appDelegate = UIApplication.shared.appDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
        } catch {
        }

    }
    
    func update(entity: String, with keyedValues: [String: Any], then handler: DBOperationHandler? = nil) {
        guard let appDelegate = UIApplication.shared.appDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            let object = try context.existingObject(with: objectID)
            
            object.setValuesForKeys(keyedValues)
            
            do {
                try context.save()
                
                handler?(.result(object: object))
            } catch {
                handler?(.error(error: .writeFailed))
            }
        } catch {
            handler?(.error(error: .readFailed))
        }
    }
    
    func remove(entity: String, then handler: DBOperationHandler? = nil) {
        guard let appDelegate = UIApplication.shared.appDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            let object = try context.existingObject(with: objectID)
            
            context.delete(object)
            
            do {
                try context.save()
                
                handler?(.result(object: object))
            } catch {
                handler?(.error(error: .writeFailed))
            }
        } catch {
            handler?(.error(error: .readFailed))
        }
    }
    
    static func hasResult(entity: String, with predicate: NSPredicate? = nil) -> Bool {
        guard let appDelegate = UIApplication.shared.appDelegate else {
            return false
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        do {
            let response = try context.fetch(fetchRequest)
            
            return !response.isEmpty
        } catch {
            return false
        }
    }
}
