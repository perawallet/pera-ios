// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import XCTest
import CoreData
@testable import pera_wallet_core

final class AppGroupDataStoreMigrationTests: XCTestCase {
    
    let APP_GROUP = "group.com.peralda.perawallet.staging"
        
    func test_migration_movesDataAndDeletesOldStore() throws {
        let migration: AppGroupDataStoreMigration = AppGroupDataStoreMigration(appGroup: APP_GROUP)
        
        let oldLocationContainer = try NSPersistentContainer.makePersistentContainer(group: nil)
        ApplicationConfiguration.create(entity: "ApplicationConfiguration", with: [
            ApplicationConfiguration.DBKeys.isDefaultNodeActive.rawValue: true,
            ApplicationConfiguration.DBKeys.password.rawValue: "pwd"
        ], in: oldLocationContainer)
        Contact.create(entity: Contact.entityName, with: [
            "identifier": "some-contact",
            "address": "some-address",
            "name": "some-name"
        ], in: oldLocationContainer)
        
        //Destroy the new store in case it exists to allow migration to run
        try deletePersistentStore(APP_GROUP)
        
        // WHEN: Running migration
        do {
            try migration.moveDatabaseToAppGroup()
        } catch {
            XCTFail(error.localizedDescription)
        }
            
    }
    
    func test_migration_doesNotRunWhenNoData() throws {
        let migration: AppGroupDataStoreMigration = AppGroupDataStoreMigration(appGroup: APP_GROUP)

        //start fresh
        try deletePersistentStore(nil)
        try deletePersistentStore(APP_GROUP)
        
        // Now ensure there's some data in the new container
        let newPersistentContainer = try NSPersistentContainer.makePersistentContainer(group: APP_GROUP)
        
        //create a data entry in the new place
        ApplicationConfiguration.create(entity: "ApplicationConfiguration", with: [
            ApplicationConfiguration.DBKeys.isDefaultNodeActive.rawValue: true,
            ApplicationConfiguration.DBKeys.password.rawValue: "pwd"
        ], in: newPersistentContainer)
        
        try migration.moveDatabaseToAppGroup()
                
        let migratedAppConfig = ApplicationConfiguration.fetchAllSyncronous(entity: "ApplicationConfiguration", in: newPersistentContainer)
        let newConfig: ApplicationConfiguration? = castResult(migratedAppConfig)
        XCTAssertEqual(newConfig?.password, "pwd")
    }
    
    func test_migration_doesNotMigrateWhenNewDatabaseButDeletesOld() throws {
        let migration: AppGroupDataStoreMigration = AppGroupDataStoreMigration(appGroup: APP_GROUP)
        
        let oldLocationContainer = try NSPersistentContainer.makePersistentContainer(group: nil)
        ApplicationConfiguration.create(entity: "ApplicationConfiguration", with: [
            ApplicationConfiguration.DBKeys.isDefaultNodeActive.rawValue: true,
            ApplicationConfiguration.DBKeys.password.rawValue: "pwd"
        ], in: oldLocationContainer)
        Contact.create(entity: Contact.entityName, with: [
            "identifier": "some-contact",
            "address": "some-address",
            "name": "some-name"
        ], in: oldLocationContainer)
        
        let newLocationContainer = try NSPersistentContainer.makePersistentContainer(group: APP_GROUP)
        ApplicationConfiguration.create(entity: "ApplicationConfiguration", with: [
            ApplicationConfiguration.DBKeys.isDefaultNodeActive.rawValue: true,
            ApplicationConfiguration.DBKeys.password.rawValue: "pwd-new"
        ], in: newLocationContainer)
        Contact.create(entity: Contact.entityName, with: [
            "identifier": "some-contact-new",
            "address": "some-address-new",
            "name": "some-name-new"
        ], in: newLocationContainer)
        
        // WHEN: Running migration
        do {
            try migration.moveDatabaseToAppGroup()
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        // THEN: App group DB should exist
        let storeURL = try URL.appGroupDBURL(for: APP_GROUP, databaseName: "algorand")
        XCTAssertTrue(FileManager.default.fileExists(atPath: storeURL.path))
        
        // THEN: Old store should be deleted
        
        let remainingFiles = try FileManager.default.contentsOfDirectory(
            at: oldLocationContainer.persistentStoreDescriptions.filter({$0.url?.lastPathComponent == "algorand.sqlite"}).first!.url!.deletingLastPathComponent(),
            includingPropertiesForKeys: nil
        )
        
        remainingFiles.forEach({ print("MIGRATION: Found remaining file: \($0)")})
        XCTAssertTrue(remainingFiles.isEmpty, "Old store files were not deleted: \(remainingFiles)")
        
        // THEN: Data should be present in the app group store
        guard let newPersistentContainer = CoreAppConfiguration.shared?.persistentContainer else {
            XCTAssertFalse(true, "Can't open new container")
            return
        }
        
        let migratedAppConfig = ApplicationConfiguration.fetchAllSyncronous(entity: "ApplicationConfiguration", in: newPersistentContainer)
        let newConfig: ApplicationConfiguration? = castResult(migratedAppConfig)
        XCTAssertEqual(newConfig?.isDefaultNodeActive, true)
        XCTAssertEqual(newConfig?.password, "pwd-new")
        
        let migratedContact = Contact.fetchAllSyncronous(entity: Contact.entityName, in: newPersistentContainer)
        let newContact: Contact? = castResult(migratedContact)
        XCTAssertEqual(newContact?.identifier, "some-contact-new")
        XCTAssertEqual(newContact?.address, "some-address-new")
        XCTAssertEqual(newContact?.name, "some-name-new")
    }
    
    func test_migration_invalidGroup() throws {
        let migration: AppGroupDataStoreMigration = AppGroupDataStoreMigration(appGroup: "not.the.right.group")

        let oldLocationContainer = try NSPersistentContainer.makePersistentContainer(group: nil)
        ApplicationConfiguration.create(entity: "ApplicationConfiguration", with: [
            ApplicationConfiguration.DBKeys.isDefaultNodeActive.rawValue: true,
            ApplicationConfiguration.DBKeys.password.rawValue: "pwd"
        ], in: oldLocationContainer)
        Contact.create(entity: Contact.entityName, with: [
            "identifier": "some-contact",
            "address": "some-address",
            "name": "some-name"
        ], in: oldLocationContainer)
        
        // WHEN: Running migration
        do {
            try migration.moveDatabaseToAppGroup()
            XCTFail("expected exception")
        } catch {
        }
    }
    
    private func castResult<T>(_ result: DBOperationResult<T>) -> T? {
        switch result {
        case .result(let object):
            return object as? T
        case .results(let objects):
            return objects.first as? T
        case .error:
            return nil
        }
    }
    
    private func deletePersistentStore(_ group: String?) throws {
        let newLocationContainer = try NSPersistentContainer.makePersistentContainer(group: group)
        let newStoreCoordinator = newLocationContainer.persistentStoreCoordinator
        for store in newStoreCoordinator.persistentStores {
            if let url = store.url {
                let type = NSPersistentStore.StoreType(rawValue: store.type)
                
                try newStoreCoordinator.destroyPersistentStore(at: url, type: type)
                
                let remainingFiles = try FileManager.default.contentsOfDirectory(
                    at: url.deletingLastPathComponent(),
                    includingPropertiesForKeys: nil
                )
                
                remainingFiles.forEach({ try? FileManager.default.removeItem(at: $0) })
            }
        }
        
    }
}


