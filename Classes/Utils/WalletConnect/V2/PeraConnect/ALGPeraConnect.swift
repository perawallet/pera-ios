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

//   ALGPeraConnect.swift

import Foundation

final class ALGPeraConnect: PeraConnect {
    var eventHandler: EventHandler?
    private(set) var walletConnectCoordinator: WalletConnectCoordinator
    
    init(
        walletConnectCoordinator: WalletConnectCoordinator
    ) {
        self.walletConnectCoordinator = walletConnectCoordinator
        
        setWalletConnectCoordinatorEvents()
    }
}

extension ALGPeraConnect {
    private func setWalletConnectCoordinatorEvents() {
        walletConnectCoordinator.eventHandler = {
            [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .shouldStartV1(let session, let preferences, let completion):
                break
            case .didConnectToV1(let session):
                break
            case .didDisconnectFromV1(let session):
                break
            case .didFailToConnectV1(let error):
                break
            case .didExceedMaximumSessionFromV1:
                break
            case .sessionsV2(let sessions):
                break
            case .proposeSessionV2(let proposal):
                break
            case .deleteSessionV2(let topic, let reason):
                break
            case .settleSessionV2(let session):
                break
            case .updateSessionV2(let topic, let namespaces):
                break
            case .extendSessionV2(let topic, let date):
                break
            case .pingV2(let ping):
                break
            case .transactionRequestV2(let request):
                break
            }
        }
    }
}

extension ALGPeraConnect {
    func isValidSession(_ session: WalletConnectSessionText) -> Bool {
        walletConnectCoordinator.isValidSession(session: session)
    }
}

extension ALGPeraConnect {
    func connectToSession(with preferences: WalletConnectSessionCreationPreferences) {
        walletConnectCoordinator.connectToSession(with: preferences)
    }
    
    func reconnectToSession(_ params: WalletConnectSessionReconnectionParams) {
        walletConnectCoordinator.reconnectToSession(params)
    }
    
    func disconnectFromSession(_ params: WalletConnectSessionDisconnectionParams) {
        walletConnectCoordinator.disconnectFromSession(params)
    }
    
    func updateSessionConnection(_ params: WalletConnectUpdateSessionConnectionParams) {
        walletConnectCoordinator.updateSessionConnection(params)
    }
    
    func extendSessionConnection(_ params: WalletConnectExtendSessionConnectionParams) {
        walletConnectCoordinator.extendSessionConnection(params)
    }
}

extension ALGPeraConnect {
    func approveSessionConnection(_ params: WalletConnectApproveSessionConnectionParams) {
        walletConnectCoordinator.approveSessionConnection(params)
    }
    
    func rejectSessionConnection(_ params: WalletConnectRejectSessionConnectionParams) {
        walletConnectCoordinator.rejectSessionConnection(params)
    }
}

extension ALGPeraConnect {
    func approveTransactionRequest(_ params: WalletConnectApproveTransactionRequestParams) {
        walletConnectCoordinator.approveTransactionRequest(params)
    }
    
    func rejectTransactionRequest(_ params: WalletConnectRejectTransactionRequestParams) {
        walletConnectCoordinator.rejectTransactionRequest(params)
    }
}
