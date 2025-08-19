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

//   ALGWalletConnectProtocolResolver.swift

public final class ALGWalletConnectProtocolResolver: WalletConnectProtocolResolver {
    public private(set) var currentWalletConnectProtocol: WalletConnectProtocol?
    public private(set) var currentWalletConnectProtocolID: WalletConnectProtocolID?
    public private(set) var walletConnectV1Protocol: WalletConnectV1Protocol
    public private(set) var walletConnectV2Protocol: WalletConnectV2Protocol
    
    private let analytics: ALGAnalytics

    public init(analytics: ALGAnalytics ) {
        self.analytics = analytics

        self.walletConnectV1Protocol = WalletConnectV1Protocol(analytics: analytics)
        self.walletConnectV2Protocol = WalletConnectV2Protocol(analytics: analytics)
    }
    
    public func getWalletConnectProtocol(from session: WalletConnectSessionText) -> WalletConnectProtocol? {
        if walletConnectV1Protocol.isValidSession(session) {
            setCurrentWalletConnectProtocolAsV1()
            return walletConnectV1Protocol
        }
        
        if walletConnectV2Protocol.isValidSession(session) {
            setCurrentWalletConnectProtocolAsV2()
            return walletConnectV2Protocol
        }
        
        resetCurrentWalletConnectProtocol()
        return nil
    }
    
    public func getWalletConnectProtocol(from id: WalletConnectProtocolID) -> WalletConnectProtocol {
        switch id {
        case .v1:
            setCurrentWalletConnectProtocolAsV1()
            return walletConnectV1Protocol
        case .v2:
            setCurrentWalletConnectProtocolAsV2()
            return walletConnectV2Protocol
        }
    }
}

extension ALGWalletConnectProtocolResolver {
    private func setCurrentWalletConnectProtocolAsV1() {
        currentWalletConnectProtocol = walletConnectV1Protocol
        currentWalletConnectProtocolID = .v1
    }
    
    private func setCurrentWalletConnectProtocolAsV2() {
        currentWalletConnectProtocol = walletConnectV2Protocol
        currentWalletConnectProtocolID = .v2
    }
    
    private func resetCurrentWalletConnectProtocol() {
        currentWalletConnectProtocol = nil
        currentWalletConnectProtocolID = nil
    }
}
