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

//   PeraConnect.swift

import Foundation

protocol PeraConnect {
    typealias EventHandler = (PeraConnectEvent) -> Void

    var eventHandler: EventHandler? { get set }    
    var walletConnectCoordinator: WalletConnectCoordinator { get }
    
    func isValidSession(_ session: WalletConnectSessionText) -> Bool
    
    func connectToSession(with preferences: WalletConnectSessionCreationPreferences)
    func reconnectToSession(_ params: WalletConnectSessionReconnectionParams)
    func disconnectFromSession(_ params: WalletConnectSessionDisconnectionParams)
    func approveSessionConnection(_ params: WalletConnectApproveSessionConnectionParams)
    func rejectSessionConnection(_ params: WalletConnectRejectSessionConnectionParams)
    func updateSessionConnection(_ params: WalletConnectUpdateSessionConnectionParams)
    func extendSessionConnection(_ params: WalletConnectExtendSessionConnectionParams)

    func approveTransactionRequest(_ params: WalletConnectApproveTransactionRequestParams)
    func rejectTransactionRequest(_ params: WalletConnectRejectTransactionRequestParams)
}

enum PeraConnectEvent {    
    case shouldStartV1(
        session: WalletConnectSession,
        preferences: WalletConnectSessionCreationPreferences?,
        completion: WalletConnectSessionConnectionCompletionHandler
    )
    case didConnectToV1(WCSession)
    case didDisconnectFromV1(WCSession)
    case didFailToConnectV1(WalletConnectV1Protocol.WCError)
    case didExceedMaximumSessionFromV1
    case sessionsV2([WalletConnectV2Session])
    case proposeSessionV2(WalletConnectV2SessionProposal)
    case deleteSessionV2(
        topic: WalletConnectTopic,
        reason: WalletConnectV2Reason
    )
    case settleSessionV2(WalletConnectV2Session)
    case updateSessionV2(
        topic: WalletConnectTopic,
        namespaces: SessionNamespaces
    )
    case extendSessionV2(
        topic: WalletConnectTopic,
        date: Date
    )
    case pingV2(String)
    case transactionRequestV2(WalletConnectV2Request)
}
