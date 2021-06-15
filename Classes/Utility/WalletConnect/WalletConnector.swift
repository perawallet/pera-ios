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

    weak var delegate: WalletConnectorDelegate?

    init() {
        walletConnectBridge.delegate = self
    }
}

extension WalletConnector {
    // Register the actions that WalletConnect is able to handle.
    func register(for action: WalletConnectMethod) {
        switch action {
        case .transactionSign:
            walletConnectBridge.register(TransactionSignRequestHandler())
        }
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

    func disconnectFromSession(_ session: WalletConnectSession) {
        do {
            try walletConnectBridge.disconnect(from: session)
        } catch {
            DispatchQueue.main.async {
                self.delegate?.walletConnector(self, didFailWith: .failedToDisconnect(session: session))
            }
        }
    }

    func reconnectToSavedSessionsIfPossible() {
        if let user = UIApplication.shared.appConfiguration?.session.authenticatedUser {
            for session in user.allWalletConnectSessions() {
                do {
                    try walletConnectBridge.reconnect(to: session.sessionDetail)
                } catch {
                    removeFromSessions(session.sessionDetail)
                }
            }
        }
    }
}

extension WalletConnector {
    private func addToSavedSessions(_ session: WalletConnectSession) {
        if let user = UIApplication.shared.appConfiguration?.session.authenticatedUser {
            user.addWalletConnectSession(WCSession(sessionDetail: session, date: Date()))
        }
    }

    private func removeFromSessions(_ session: WalletConnectSession) {
        if let user = UIApplication.shared.appConfiguration?.session.authenticatedUser {
            user.removeWalletConnectSession(url: session.url)
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
        DispatchQueue.main.async {
            self.addToSavedSessions(session)
            self.delegate?.walletConnector(self, didConnectTo: session)
        }
    }

    func walletConnectBridge(_ walletConnectBridge: WalletConnectBridge, didDisconnectFrom session: WalletConnectSession) {
        DispatchQueue.main.async {
            self.removeFromSessions(session)
            self.delegate?.walletConnector(self, didDisconnectFrom: session)
        }
    }
}

extension WalletConnector {
    enum Error {
        case failedToConnect(url: WalletConnectURL)
        case failedToCreateSession(qr: String)
        case failedToDisconnect(session: WalletConnectSession)
    }
}

protocol WalletConnectorDelegate: AnyObject {
    func walletConnector(
        _ walletConnector: WalletConnector,
        shouldStart session: WalletConnectSession,
        then completion: @escaping WalletConnectSessionConnectionCompletionHandler
    )
    func walletConnector(_ walletConnector: WalletConnector, didConnectTo session: WalletConnectSession)
    func walletConnector(_ walletConnector: WalletConnector, didDisconnectFrom session: WalletConnectSession)
    func walletConnector(_ walletConnector: WalletConnector, didFailWith error: WalletConnector.Error)
}

enum WalletConnectMethod: String {
    case transactionSign = "algo_signTxn"
}
