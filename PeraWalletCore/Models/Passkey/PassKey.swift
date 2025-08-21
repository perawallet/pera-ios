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
import Foundation

@objc(PassKey)
public final class PassKey: NSManagedObject, Identifiable {
    @NSManaged public var origin: String
    @NSManaged public var username: String
    @NSManaged public var displayName: String
    @NSManaged public var address: String
    @NSManaged public var credentialId: String
    @NSManaged public var lastUsed: Date?
}

extension PassKey {
    
    public var lastUsedDisplay: String {
        String(format: String(localized: "settings-passkeys-last-used"), lastUsed?.toFormat("MMM d, yyyy, h:mm a") ?? "Never")
    }
    
    public enum DBKeys: String {
        case origin
        case username
        case displayName
        case address
        case credentialId
        case lastUsed
    }
}

extension PassKey {
    public static let entityName = "PassKey"
}

extension PassKey: DBStorable { }
