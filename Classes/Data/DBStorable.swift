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
    static func fetchAll(entity: String, with predicate: NSPredicate?, then handler: DBOperationHandler?)
    
    func update(entity: String, with keyedValues: [String: Any], then handler: DBOperationHandler?)
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
    
    static func fetchAll(entity: String, with predicate: NSPredicate? = nil, then handler: DBOperationHandler? = nil) {
        guard let appDelegate = UIApplication.shared.appDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        do {
            let response = try context.fetch(fetchRequest)
            
            handler?(.results(objects: response))
        } catch {
            handler?(.error(error: .readFailed))
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
}
