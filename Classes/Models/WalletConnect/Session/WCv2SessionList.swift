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

//   WCv2SessionList.swift

import CoreData

@objc(WCv2SessionList)
public final class WCv2SessionList: NSManagedObject {
    @NSManaged public var sessions: Data?

    var wcSessions: [String: WalletConnectV2SessionEntity]? {
        guard let data = sessions else {
            return nil
        }
        return try? JSONDecoder().decode([String: WalletConnectV2SessionEntity].self, from: data)
    }
}

extension WCv2SessionList {
    enum DBKeys: String {
        case sessions = "sessions"
    }
}

extension WCv2SessionList {
    static let entityName = "WCv2SessionList"
}

extension WCv2SessionList: DBStorable { }
