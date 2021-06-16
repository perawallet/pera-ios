// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   WalletConnectSessionSource.swift

import Foundation

class WalletConnectSessionSource {

    var sessions: [WalletConnectURL: WCSession]? {
        get {
            return wcSessionList?.wcSessions
        }

        set {
            guard let sessionData = try? JSONEncoder().encode(newValue) else {
                return
            }

            if let wcSession = wcSessionList {
                wcSession.update(
                    entity: WCSessionList.entityName,
                    with: [WCSessionList.DBKeys.sessions.rawValue: sessionData]
                )
            } else {
                WCSessionList.create(
                    entity: WCSessionList.entityName,
                    with: [WCSessionList.DBKeys.sessions.rawValue: sessionData]
                )
            }

            Cache.wcSessionList = wcSessionList
        }
    }

    private var wcSessionList: WCSessionList? {
        get {
            if Cache.wcSessionList == nil {
                guard WCSessionList.hasResult(entity: WCSessionList.entityName) else {
                    return nil
                }

                let result = WCSessionList.fetchAllSyncronous(entity: WCSessionList.entityName)

                switch result {
                case .result(let object):
                    if let session = object as? WCSessionList {
                        Cache.wcSessionList = session
                        return Cache.wcSessionList
                    }
                case .results(let objects):
                    if let session = objects.first(where: { $0 is WCSessionList }) as? WCSessionList {
                        Cache.wcSessionList = session
                        return Cache.wcSessionList
                    }
                case .error:
                    return nil
                }
            }

            return Cache.wcSessionList
        }

        set {
            Cache.wcSessionList = newValue
        }
    }
}

extension WalletConnectSessionSource {
    func addWalletConnectSession(_ session: WCSession) {
        if sessions != nil {
            if sessions?[session.sessionDetail.url] != nil {
                return
            }

            self.sessions?[session.sessionDetail.url] = session
            syncSessions()
        } else {
            sessions = [session.sessionDetail.url: session]
        }
    }

    var allWalletConnectSessions: [WCSession] {
        if let wcSessions = sessions {
            return Array(wcSessions.values)
        }

        return []
    }

    func getWalletConnectSession(with url: WalletConnectURL) -> WCSession? {
        return sessions?[url]
    }

    func removeWalletConnectSession(with url: WalletConnectURL) {
        _ = sessions?.removeValue(forKey: url)
        syncSessions()
    }

    func resetAllSessions() {
        wcSessionList = nil
        WCSessionList.clear(entity: WCSessionList.entityName)
    }

    private func syncSessions() {
        self.sessions = sessions
    }
}

extension WalletConnectSessionSource {
    private enum Cache {
        static var wcSessionList: WCSessionList?
    }
}
