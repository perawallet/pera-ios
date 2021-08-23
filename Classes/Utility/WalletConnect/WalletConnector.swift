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
//   WalletConnector.swift

import WalletConnectSwift

class WalletConnector {

    private let walletConnectBridge = WalletConnectBridge()

    private lazy var sessionSource = WalletConnectSessionSource()

    weak var delegate: WalletConnectorDelegate?

    init() {
        walletConnectBridge.delegate = self
    }
}

extension WalletConnector {
    // Register the actions that WalletConnect is able to handle.
    func register(for handler: WalletConnectRequestHandler) {
        walletConnectBridge.register(handler)
    }

    func connect(to session: String) {
        guard let url = WalletConnectURL(session) else {
            DispatchQueue.main.async {
                self.delegate?.walletConnector(self, didFailWith: .failedToCreateSession(qr: session))
            }
            return
        }

        do {
            try walletConnectBridge.connect(to: url)
        } catch {
            DispatchQueue.main.async {
                self.delegate?.walletConnector(self, didFailWith: .failedToConnect(url: url))
            }
        }
    }

    func disconnectFromSession(_ session: WCSession) {
        do {
            try walletConnectBridge.disconnect(from: session.sessionBridgeValue)
        } catch {
            DispatchQueue.main.async {
                self.delegate?.walletConnector(self, didFailWith: .failedToDisconnect(session: session))
            }
        }
    }

    func reconnectToSavedSessionsIfPossible() {
        for session in allWalletConnectSessions {
            do {
                try walletConnectBridge.reconnect(to: session.sessionBridgeValue)
            } catch {
                removeFromSessions(session)
            }
        }
    }

    func signTransactionRequest(_ request: WalletConnectRequest, with signature: [Data?]) {
        walletConnectBridge.signTransactionRequest(request, with: signature)
    }

    func rejectTransactionRequest(_ request: WalletConnectRequest, with error: WCTransactionErrorResponse) {
        walletConnectBridge.rejectTransactionRequest(request, with: error)
    }
}

extension WalletConnector {
    private func addToSavedSessions(_ session: WCSession) {
        sessionSource.addWalletConnectSession(session)
    }

    private func removeFromSessions(_ session: WCSession) {
        sessionSource.removeWalletConnectSession(with: session.urlMeta)
    }

    var allWalletConnectSessions: [WCSession] {
        sessionSource.allWalletConnectSessions
    }

    func getWalletConnectSession(with url: WCURLMeta) -> WCSession? {
        return sessionSource.getWalletConnectSession(with: url)
    }
    
    func resetAllSessions() {
        sessionSource.resetAllSessions()
    }

    func saveConnectedWCSession(_ session: WCSession) {
        if let sessionData = try? JSONEncoder().encode([session.urlMeta.topic: session]) {
            WCSessionHistory.create(
                entity: WCSessionHistory.entityName,
                with: [WCSessionHistory.DBKeys.sessionHistory.rawValue: sessionData]
            )
        }
    }
}

extension WalletConnector: WalletConnectBridgeDelegate {
    func walletConnectBridge(
        _ walletConnectBridge: WalletConnectBridge,
        shouldStart session: WalletConnectSession,
        then completion: @escaping WalletConnectSessionConnectionCompletionHandler
    ) {
        // Get user approval or rejection for the session
        DispatchQueue.main.async {
            self.delegate?.walletConnector(self, shouldStart: session, then: completion)
        }
    }

    func walletConnectBridge(_ walletConnectBridge: WalletConnectBridge, didFailToConnect url: WalletConnectURL) {
        DispatchQueue.main.async {
            self.delegate?.walletConnector(self, didFailWith: .failedToConnect(url: url))
        }
    }

    func walletConnectBridge(_ walletConnectBridge: WalletConnectBridge, didConnectTo session: WalletConnectSession) {
        let wcSession = session.toWCSession()

        DispatchQueue.main.async {
            self.addToSavedSessions(wcSession)
            self.delegate?.walletConnector(self, didConnectTo: wcSession)
        }
    }

    func walletConnectBridge(_ walletConnectBridge: WalletConnectBridge, didDisconnectFrom session: WalletConnectSession) {
        let wcSession = session.toWCSession()

        DispatchQueue.main.async {
            self.removeFromSessions(wcSession)
            self.delegate?.walletConnector(self, didDisconnectFrom: wcSession)
        }
    }
}

extension WalletConnector {
    enum Error {
        case failedToConnect(url: WalletConnectURL)
        case failedToCreateSession(qr: String)
        case failedToDisconnect(session: WCSession)
    }
}

protocol WalletConnectorDelegate: AnyObject {
    func walletConnector(
        _ walletConnector: WalletConnector,
        shouldStart session: WalletConnectSession,
        then completion: @escaping WalletConnectSessionConnectionCompletionHandler
    )
    func walletConnector(_ walletConnector: WalletConnector, didConnectTo session: WCSession)
    func walletConnector(_ walletConnector: WalletConnector, didDisconnectFrom session: WCSession)
    func walletConnector(_ walletConnector: WalletConnector, didFailWith error: WalletConnector.Error)
}

extension WalletConnectorDelegate {
    func walletConnector(
        _ walletConnector: WalletConnector,
        shouldStart session: WalletConnectSession,
        then completion: @escaping WalletConnectSessionConnectionCompletionHandler
    ) {

    }

    func walletConnector(_ walletConnector: WalletConnector, didConnectTo session: WCSession) {

    }

    func walletConnector(_ walletConnector: WalletConnector, didDisconnectFrom session: WCSession) {

    }

    func walletConnector(_ walletConnector: WalletConnector, didFailWith error: WalletConnector.Error) {
        
    }
}

enum WalletConnectMethod: String {
    case transactionSign = "algo_signTxn"
}
