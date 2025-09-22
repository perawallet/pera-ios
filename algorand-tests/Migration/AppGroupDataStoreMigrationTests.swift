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
        
    func test_migration_movesDataAndDeletesOldStore() throws {
        let migration: AppGroupDataStoreMigration = AppGroupDataStoreMigration(appGroup: ALGAppTarget.App.staging.appGroupIdentifier)
        
        let oldLocationContainer = NSPersistentContainer.makePersistentContainer(group: nil)
        Task {
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
            migration.moveDatabaseToAppGroup()
            
            // THEN: App group DB should exist
            let storeURL = URL.appGroupDBURL(for: ALGAppTarget.App.staging.appGroupIdentifier, databaseName: "algorand")
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
            XCTAssertEqual(newConfig?.password, "pwd")
            
            let migratedContact = Contact.fetchAllSyncronous(entity: Contact.entityName, in: newPersistentContainer)
            let newContact: Contact? = castResult(migratedContact)
            XCTAssertEqual(newContact?.identifier, "some-contact")
            XCTAssertEqual(newContact?.address, "some-address")
            XCTAssertEqual(newContact?.name, "some-name")
        }
            
    }
    
    func test_migration_doesNotRunWhenNoData() throws {
        let migration: AppGroupDataStoreMigration = AppGroupDataStoreMigration(appGroup: ALGAppTarget.App.staging.appGroupIdentifier)

        let oldContainer = NSPersistentContainer(name: "algorand")
        let oldLocationContainer = oldContainer.persistentStoreDescriptions
            .filter({$0.url?.lastPathComponent.starts(with: "algorand") ?? false}).first!.url!
        
        if FileManager.default.fileExists(atPath: oldLocationContainer.path) {
            try FileManager.default.removeItem(at: oldLocationContainer)
        }
        
        // THEN: Data should be present in the app group store
        guard let newPersistentContainer = CoreAppConfiguration.shared?.persistentContainer else {
            XCTAssertFalse(true, "Can't open new container")
            return
        }
        
        //create a data entry in the new place
        ApplicationConfiguration.create(entity: "ApplicationConfiguration", with: [
            ApplicationConfiguration.DBKeys.isDefaultNodeActive.rawValue: true,
            ApplicationConfiguration.DBKeys.password.rawValue: "pwd"
        ], in: newPersistentContainer)
        
        migration.moveDatabaseToAppGroup()
                
        let migratedAppConfig = ApplicationConfiguration.fetchAllSyncronous(entity: "ApplicationConfiguration", in: newPersistentContainer)
        let newConfig: ApplicationConfiguration? = castResult(migratedAppConfig)
        XCTAssertEqual(newConfig?.password, "pwd")
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
}


