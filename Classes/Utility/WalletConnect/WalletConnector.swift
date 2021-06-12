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

    private var session: WalletConnectSession?

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
            return
        }

        do {
            try walletConnectBridge.connect(to: url)
        } catch {
            delegate?.walletConnector(self, didFailToConnect: url)
        }
    }

    func disconnectFromSession() {
        if let session = session {
            do {
                try walletConnectBridge.disconnect(from: session)
            } catch {
                delegate?.walletConnector(self, didFailToDisconnectFrom: session)
            }
        }
    }
}

extension WalletConnector {
    private func addToSavedSessions(_ session: WalletConnectSession) {
        // Will add the session to sessions list
    }

    private func removeFromSessions(_ session: WalletConnectSession) {
        // Will remove the session from sessions list
    }
}

extension WalletConnector: WalletConnectBridgeDelegate {
    func walletConnectBridge(
        _ walletConnectBridge: WalletConnectBridge,
        shouldStart session: WalletConnectSession,
        then completion: @escaping WalletConnectSessionConnectionCompletionHandler
    ) {
        // Get user approval or rejection for the session
        delegate?.walletConnector(self, shouldStart: session, then: completion)
    }

    func walletConnectBridge(_ walletConnectBridge: WalletConnectBridge, didFailToConnect url: WalletConnectURL) {
        delegate?.walletConnector(self, didFailToConnect: url)
    }

    func walletConnectBridge(_ walletConnectBridge: WalletConnectBridge, didConnectTo session: WalletConnectSession) {
        self.session = session
        addToSavedSessions(session)
        delegate?.walletConnector(self, didConnectTo: session)
    }

    func walletConnectBridge(_ walletConnectBridge: WalletConnectBridge, didDisconnectFrom session: WalletConnectSession) {
        self.session = nil
        removeFromSessions(session)
        delegate?.walletConnector(self, didDisconnectFrom: session)
    }
}

protocol WalletConnectorDelegate: AnyObject {
    func walletConnector(
        _ walletConnector: WalletConnector,
        shouldStart session: WalletConnectSession,
        then completion: @escaping WalletConnectSessionConnectionCompletionHandler
    )
    func walletConnector(_ walletConnector: WalletConnector, didFailToConnect url: WalletConnectURL)
    func walletConnector(_ walletConnector: WalletConnector, didConnectTo session: WalletConnectSession)
    func walletConnector(_ walletConnector: WalletConnector, didDisconnectFrom session: WalletConnectSession)
    func walletConnector(_ walletConnector: WalletConnector, didFailToDisconnectFrom session: WalletConnectSession)
}

enum WalletConnectMethod: String {
    case transactionSign = "algo_signTxn"
}
