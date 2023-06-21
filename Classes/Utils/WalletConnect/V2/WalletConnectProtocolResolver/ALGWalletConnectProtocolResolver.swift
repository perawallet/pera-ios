// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ALGWalletConnectProtocolResolver.swift

final class ALGWalletConnectProtocolResolver: WalletConnectProtocolResolver {
    private(set) var currentWalletConnectProtocol: WalletConnectProtocol?
    
    private lazy var walletConnectV1Protocol = WalletConnector(
        api: api,
        pushToken: pushToken,
        analytics: analytics
    )
    
    private lazy var walletConnectV2Protocol = WalletConnectV2Protocol(api: api)
    
    private let api: ALGAPI
    private let analytics: ALGAnalytics
    private let pushToken: String?
    
    init(
        api: ALGAPI,
        analytics: ALGAnalytics,
        pushToken: String?
    ) {
        self.api = api
        self.analytics = analytics
        self.pushToken = pushToken
    }
    
    func getWalletConnectProtocol(from session: WalletConnectSessionText) -> WalletConnectProtocol? {
        if walletConnectV1Protocol.isValidSession(session) {
            currentWalletConnectProtocol = walletConnectV1Protocol
            return walletConnectV1Protocol
        }
        
        if walletConnectV2Protocol.isValidSession(session) {
            currentWalletConnectProtocol = walletConnectV2Protocol
            return walletConnectV2Protocol
        }
        
        currentWalletConnectProtocol = nil
        return nil
    }
    
    func getWalletConnectProtocol(from id: WalletConnectProtocolID) -> WalletConnectProtocol? {
        switch id {
        case .v1:
            currentWalletConnectProtocol = walletConnectV1Protocol
        case .v2:
            currentWalletConnectProtocol = walletConnectV2Protocol
        }
        
        return currentWalletConnectProtocol
    }
}
