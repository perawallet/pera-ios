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

import Foundation
import CoreData

public final class AppGroupDataStoreMigration {
    private let appGroup: String
    
    public init(appGroup: String) {
        self.appGroup = appGroup
    }

    public func moveDatabaseToAppGroup() throws {
        // Open the old database container and see if we have an ApplicationConfiguration there.  If so move everything to the app group location
        // and delete the old stuff
        let persistentContainer = NSPersistentContainer(name: NSPersistentContainer.DEFAULT_CONTAINER_NAME) //this is the old DB location
                
        let dbWithContent = try persistentContainer.persistentStoreDescriptions
            .first { desc in
                if let url = desc.url, url.lastPathComponent.starts(with: NSPersistentContainer.DEFAULT_CONTAINER_NAME) {
                    return try hasContents(url)
                }
                return false
            }
        
        guard dbWithContent != nil else {
            return
        }
        
        let loadedDB = try NSPersistentContainer.makePersistentContainer(group: nil)
        try performMigration(from: loadedDB)
    }
    
    private func performMigration(from: NSPersistentContainer) throws(AppGroupDataStoreMigrationError) {
        do {
            let storeURL = try URL.appGroupDBURL(for: appGroup, databaseName: NSPersistentContainer.DEFAULT_CONTAINER_NAME)
            let oldStoreCoordinator = from.persistentStoreCoordinator
            
            for store in oldStoreCoordinator.persistentStores {
                if let url = store.url {
                    let type = NSPersistentStore.StoreType(rawValue: store.type)
                    try oldStoreCoordinator.replacePersistentStore(at: storeURL,
                                                                   withPersistentStoreFrom: url,
                                                                   type: type)
                    try oldStoreCoordinator.destroyPersistentStore(at: url, type: type)
                    
                    let remainingFiles = try FileManager.default.contentsOfDirectory(
                        at: url.deletingLastPathComponent(),
                        includingPropertiesForKeys: nil
                    )
                    
                    remainingFiles.forEach({ try? FileManager.default.removeItem(at: $0) })
                }
            }
            
            CoreAppConfiguration.shared?.persistentContainer = try NSPersistentContainer.makePersistentContainer(group: appGroup)
        } catch {
            throw AppGroupDataStoreMigrationError.migrationFailed(cause: error)
        }
    }
    
    private func hasContents(_ url: URL) throws(AppGroupDataStoreMigrationError) -> Bool {
        do {
            let parent = url.deletingLastPathComponent()
            let name = url.lastPathComponent
            return try FileManager.default.contentsOfDirectory(at: parent, includingPropertiesForKeys: nil, options: [])
                .filter {
                    $0.lastPathComponent.hasPrefix(name)
                }
                .isNonEmpty
        } catch {
            throw AppGroupDataStoreMigrationError.contentNotDetected(cause: error)
        }
    }
}

public enum AppGroupDataStoreMigrationError: Error {
    case migrationFailed(cause: Error? = nil)
    case contentNotDetected(cause: Error? = nil)
    case generalError(cause: Error? = nil)
    
    public var cause: Error? {
        switch self {
        case .migrationFailed(cause: let cause),
             .contentNotDetected(cause: let cause),
             .generalError(cause: let cause):
            return cause
        }
        return nil
    }
}
