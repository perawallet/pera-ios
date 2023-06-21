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

//   ALGWalletConnectCoordinator.swift

import Foundation

final class ALGWalletConnectCoordinator: WalletConnectCoordinator {
    let walletConnectProtocolResolver: WalletConnectProtocolResolver
    
    init(
        walletConnectProtocolResolver: WalletConnectProtocolResolver
    ) {
        self.walletConnectProtocolResolver = walletConnectProtocolResolver
    }
    
    func connect() {
        guard let currentProtocol = currentProtocol(from: "") else { return }
    }
    
    func reconnect() {
        
    }
    
    func disconnect() {
        
    }
    
    func approveSession() {
        
    }
    
    func rejectSession() {
        
    }
    
    func updateSession() {
        
    }
    
    func approveRequest() {
        
    }
    
    func rejectRequest() {
        
    }
}

extension ALGWalletConnectCoordinator {
    func currentProtocol(from sessionText: WalletConnectSessionText) -> WalletConnectProtocol? {
        return walletConnectProtocolResolver.getWalletConnectProtocol(from: sessionText)
    }
    
    func currentProtocol(from protocolID: WalletConnectProtocolID) -> WalletConnectProtocol? {
        return walletConnectProtocolResolver.getWalletConnectProtocol(from: protocolID)
    }
}
