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
//   WalletConnectBridge.swift

import WalletConnectSwift

class WalletConnectBridge {

    weak var delegate: WalletConnectBridgeDelegate?

    private(set) lazy var walletConnectServer = WalletConnectServer(delegate: self)
}

extension WalletConnectBridge {
    func register(_ handler: WalletConnectRequestHandler) {
        walletConnectServer.register(handler: handler)
    }

    func connect(to url: WCURL) throws {
        try walletConnectServer.connect(to: url)
    }

    func reconnect(to session: WalletConnectSession) throws {
        try walletConnectServer.reconnect(to: session)
    }

    func disconnect(from session: WalletConnectSession) throws {
        try walletConnectServer.disconnect(from: session)
    }
}

extension WalletConnectBridge: ServerDelegate {
    func server(
        _ server: WalletConnectServer,
        shouldStart session: WalletConnectSession,
        completion: @escaping (WalletConnectSession.WalletInfo) -> Void
    ) {
        delegate?.walletConnectBridge(self, shouldStart: session, then: completion)
    }

    func server(_ server: WalletConnectServer, didConnect session: WalletConnectSession) {
        delegate?.walletConnectBridge(self, didConnectTo: session)
    }

    func server(_ server: WalletConnectServer, didDisconnect session: WalletConnectSession) {
        delegate?.walletConnectBridge(self, didDisconnectFrom: session)
    }

    func server(_ server: WalletConnectServer, didFailToConnect url: WalletConnectURL) {
        delegate?.walletConnectBridge(self, didFailToConnect: url)
    }
}

protocol WalletConnectBridgeDelegate: AnyObject {
    func walletConnectBridge(
        _ walletConnectBridge: WalletConnectBridge,
        shouldStart session: WalletConnectSession,
        then completion: (WalletConnectSession.WalletInfo) -> Void
    )
    func walletConnectBridge(_ walletConnectBridge: WalletConnectBridge, didFailToConnect url: WalletConnectURL)
    func walletConnectBridge(_ walletConnectBridge: WalletConnectBridge, didConnectTo session: WalletConnectSession)
    func walletConnectBridge(_ walletConnectBridge: WalletConnectBridge, didDisconnectFrom session: WalletConnectSession)
}

typealias WalletConnectSession = WalletConnectSwift.Session
typealias WalletConnectURL = WCURL
typealias WalletConnectServer = Server
typealias WalletConnectRequest = WalletConnectSwift.Request
typealias WalletConnectResponse = WalletConnectSwift.Response
