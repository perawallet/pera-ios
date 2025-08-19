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

    public func moveDatabaseToAppGroup() {
        // Open the old database container and see if we have an ApplicationConfiguration there.  If so move everything to the app group location
        // and delete the old stuff
        let persistentContainer = NSPersistentContainer(name: "algorand") //this is the old DB location
                
        do {
            let dbWithContent = try persistentContainer.persistentStoreDescriptions
                .first(where: { desc in
                    if let url = desc.url, url.lastPathComponent.starts(with: "algorand") {
                        return try hasContents(url)
                    }
                    return false
                })
            
            if dbWithContent != nil {
                let loadedDB = NSPersistentContainer.makePersistentContainer(group: nil)
                try doMigration(from: loadedDB)
            }
        } catch {
            print("Failed to clear old DB during app group migration: \(error)")
        }
    }
    
    private func doMigration(from: NSPersistentContainer) throws {
        let storeURL = URL.appGroupDBURL(for: appGroup, databaseName: "algorand")
        let oldStoreCoordinator = from.persistentStoreCoordinator
        
        for store in from.persistentStoreCoordinator.persistentStores {
            try oldStoreCoordinator.migratePersistentStore(store, to: storeURL, options: nil, withType: NSSQLiteStoreType)
        }
    }
    
    private func hasContents(_ url: URL) throws -> Bool {
        let parent = url.deletingLastPathComponent()
        let name = url.lastPathComponent
        return try FileManager.default.contentsOfDirectory(at: parent, includingPropertiesForKeys: nil, options: [])
            .filter {
                $0.lastPathComponent.hasPrefix(name)
            }
            .count > 0
    }
    
    
}
