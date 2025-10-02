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

import CoreData

extension NSPersistentContainer {
    public static let DEFAULT_CONTAINER_NAME = "algorand"
    
    public static func makePersistentContainer(group: String?) throws -> NSPersistentContainer {
        let container = NSPersistentContainer(name: DEFAULT_CONTAINER_NAME)
        
        if let group {
            let storeURL = try URL.appGroupDBURL(for: group, databaseName: DEFAULT_CONTAINER_NAME)
            let storeDescription = NSPersistentStoreDescription(url: storeURL)
            container.persistentStoreDescriptions = [storeDescription]
        }
        container.loadPersistentStores { storeDescription, error in
            if var url = storeDescription.url {
                var resourceValues = URLResourceValues()
                resourceValues.isExcludedFromBackup = true

                try? url.setResourceValues(resourceValues)
            }

            if let error = error as NSError? {
                CoreAppConfiguration.shared?.analytics.record(
                    PersitentContainerCreationError.persistentContainerCreationError(appGroup: group ?? "nil", errorDetails: "\(error), \(error.code), \(error.userInfo)"))
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        return container
    }
}

