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
    
    var coordinatorEventHandler: ((WalletConnectCoordinatorEvent) -> Void)?
    
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
                sendEvent(
                    .shouldStartV1(
                        session: session,
                        preferences: preferences,
                        completion: completion
                    )
                )
            case .didConnectToV1(let session):
                sendEvent(.didConnectToV1(session))
            case .didDisconnectFromV1(let session):
                sendEvent(.didDisconnectFromV1(session))
            case .didDisconnectFromV1Fail(let session, let error):
                sendEvent(.didDisconnectFromV1Fail(session: session, error: error))
            case .didFailToConnectV1(let error):
                sendEvent(.didFailToConnectV1(error))
            case .didExceedMaximumSessionFromV1:
                sendEvent(.didExceedMaximumSessionFromV1)
            case .sessionsV2(let sessions):
                sendEvent(.sessionsV2(sessions))
            case .proposeSessionV2(let proposal):
                sendEvent(.proposeSessionV2(proposal))
            case .deleteSessionV2(let topic, let reason):
                sendEvent(
                    .deleteSessionV2(
                        topic: topic,
                        reason: reason
                    )
                )
            case .settleSessionV2(let session):
                sendEvent(.settleSessionV2(session))
            case .updateSessionV2(let topic, let namespaces):
                sendEvent(
                    .updateSessionV2(
                        topic: topic,
                        namespaces: namespaces
                    )
                )
            case .didDisconnectFromV2(let session):
                sendEvent(.didDisconnectFromV2(session))
            case .didDisconnectFromV2Fail(let session, let error):
                sendEvent(.didDisconnectFromV2Fail(session: session, error: error))
            case .extendSessionV2(let topic, let date):
                sendEvent(
                    .extendSessionV2(
                        topic: topic,
                        date: date
                    )
                )
            case .pingV2(let ping):
                sendEvent(.pingV2(ping))
            case .didPingV2SessionFail(let session, let error):
                sendEvent(.didPingV2SessionFail(session: session, error: error))
            case .transactionRequestV2(let request):
                sendEvent(.transactionRequestV2(request))
            case .failure(let error):
                sendEvent(.failure(error))
            }
        }
    }
}

extension ALGPeraConnect {
    func isValidSession(_ session: WalletConnectSessionText) -> Bool {
        walletConnectCoordinator.isValidSession(session: session)
    }
    
    func configureIfNeeded() {
        walletConnectCoordinator.configureIfNeeded()
    }
}

extension ALGPeraConnect {
    func connectToSession(with preferences: WalletConnectSessionCreationPreferences) {
        walletConnectCoordinator.connectToSession(with: preferences)
    }
    
    func reconnectToSession(_ params: WalletConnectSessionReconnectionParams) {
        walletConnectCoordinator.reconnectToSession(params)
    }
    
    func disconnectFromSession(_ params: any WalletConnectSessionDisconnectionParams) {
        walletConnectCoordinator.disconnectFromSession(params)
    }

    func disconnectFromAllSessions() {
        walletConnectCoordinator.disconnectFromAllSessions()
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

extension ALGPeraConnect {
    private func sendEvent(_ event: PeraConnectEvent) {
        eventHandler?(event)
    }
}
