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

//   WalletConnectV2Protocol.swift

import Combine
import Foundation
import WalletConnectNetworking
import WalletConnectPairing
import Web3Wallet

final class WalletConnectV2Protocol: WalletConnectProtocol {
    var eventHandler: ((WalletConnectV2Event) -> Void)?
    
    private var signAPI: SignClient {
        return Sign.instance
    }
    
    private var pairAPI: PairingInteracting {
        return Pair.instance
    }
    
    private(set) var sessionValidator: WalletConnectSessionValidator
    
    private var publishers = Set<AnyCancellable>()
    
    /// Project id is from a mock app that I created.
    private let projectID = "06274a21f488344abb80fc50223631f8"
    
    /// Metadata that is directly copied from WalletConnect v1.
    private let appMetadata = AppMetadata(
        name: ALGAppTarget.current.walletConnectConfig.meta.name,
        description: ALGAppTarget.current.walletConnectConfig.meta.description,
        url: ALGAppTarget.current.walletConnectConfig.meta.url.absoluteString,
        icons: ALGAppTarget.current.walletConnectConfig.meta.icons.map { $0.absoluteString }
    )
    
    private let algorandSDK = AlgorandSDK()
    
    private let api: ALGAPI
    
    init(api: ALGAPI) {
        self.api = api
        self.sessionValidator = WalletConnectV2SessionValidator()
    }
}

extension WalletConnectV2Protocol {
    func setup() {
        Networking.configure(
            projectId: projectID,
            socketFactory: DefaultSocketFactory()
        )
        
        Pair.configure(metadata: appMetadata)

        listenEvents()
    }
}

extension WalletConnectV2Protocol {
    func connect(with preferences: WalletConnectSessionCreationPreferences) {
        guard let uri = WalletConnectURI(string: preferences.session) else { return }

        Task {
            do {
                try await pairAPI.pair(uri: uri)
            } catch {
                self.eventHandler?(.failure(error))
                print("[WC2] - Pairing connect error: \(error)")
            }
        }
    }
    
    func isValidSession(_ uri: WalletConnectSessionText) -> Bool {
        return sessionValidator.isValidSession(uri)
    }
}

extension WalletConnectV2Protocol {
    func getSessions() -> [WalletConnectV2Session] {
        return signAPI.getSessions()
    }
}

extension WalletConnectV2Protocol {
    func approveSession(
        _ proposalId: String,
        namespaces: SessionNamespaces
    ) {
        print("[WC2] - Approve Session: \(proposalId)")
        
        Task {
            do {
                try await signAPI.approve(
                    proposalId: proposalId,
                    namespaces: namespaces
                )
            } catch {
                self.eventHandler?(.failure(error))
                print("[WC2] - Approve Session error: \(error)")
            }
        }
    }

    func rejectSession(
        _ proposalId: String,
        reason: WalletConnectV2SessionRejectionReason
    ) {
        print("[WC2] - Reject Session: \(proposalId)")
        
        Task {
            do {
                try await signAPI.reject(
                    proposalId: proposalId,
                    reason: reason
                )
            } catch {
                self.eventHandler?(.failure(error))
                print("[WC2] - Reject Session error: \(error)")
            }
        }
    }
    
    func extendSession(_ session: WalletConnectV2Session) {
        print("[WC2] - Extend Session: \(session.topic)")
        
        Task {
            do {
                try await signAPI.extend(topic: session.topic)
            } catch {
                self.eventHandler?(.failure(error))
                print("[WC2] - Extend Session error: \(error)")
            }
        }
    }
    
    func updateSession(
        _ session: WalletConnectV2Session,
        namespaces: SessionNamespaces
    ) {
        print("[WC2] - Update Session: \(session.topic)")
        
        Task {
            do {
                try await signAPI.update(
                    topic: session.topic,
                    namespaces: namespaces
                )
            } catch {
                self.eventHandler?(.failure(error))
                print("[WC2] - Update Session error: \(error)")
            }
        }
    }

    func disconnectFromSession(_ session: WalletConnectV2Session) {
        print("[WC2] - Disconnect Session: \(session.topic)")

        Task {
            do {
                try await signAPI.disconnect(topic: session.topic)
                self.eventHandler?(.didDisconnectSession(session) )
            } catch {
                self.eventHandler?(.didDisconnectSessionFail(session: session, error: error))
                print("[WC2] - Disconnect Session error: \(error)")
            }
        }
    }

    func pingSession(_ session: WalletConnectV2Session) {
        print("[WC2] - Ping Session: \(session.topic)")

        Task {
            do {
                try await signAPI.ping(topic: session.topic)
            } catch {
                self.eventHandler?(.didPingSessionFail(session: session, error: error))
                print("[WC2] - Ping Session error: \(error)")
            }
        }
    }

    func disconnectFromAllSessions() {
        let sessions = getSessions()
        sessions.forEach(disconnectFromSession)
    }
}

extension WalletConnectV2Protocol {
    func approveTransactionRequest(
        _ request: WalletConnectV2Request,
        response: WalletConnectV2CodableResult
    ) {
        print("[WC2] - Approve Request")
        
        Task {
            do {
                try await signAPI.respond(
                    topic: request.topic,
                    requestId: request.id,
                    response: .response(response)
                )
            } catch {
                self.eventHandler?(.failure(error))
                print("[WC2] - Approve Request Error: \(error.localizedDescription)")
            }
        }
    }

    func rejectTransactionRequest(_ request: WalletConnectV2Request) {
        print("[WC2] - Reject Request")

        Task {
            do {
                try await signAPI.respond(
                    topic: request.topic,
                    requestId: request.id,
                    response: .error(
                        .init(
                            code: 0,
                            message: ""
                        )
                    )
                )
            } catch {
                self.eventHandler?(.failure(error))
                print("[WC2] - Reject Request Error: \(error.localizedDescription)")
            }
        }
    }
}

extension WalletConnectV2Protocol {
    private func listenEvents() {
        publishers = []

        handleSessionEvents()
        handleSessionProposalEvents()
        handleSessionDeletionEvents()
        handleSessionSettleEvents()
        handleSessionUpdateEvents()
        handleSessionExtensionEvents()
        handlePingEvents()
        handleTransactionRequestEvents()
    }
    
    private func handleSessionEvents() {
        signAPI
            .sessionsPublisher
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] sessions in
                guard let self else { return }
                
                self.eventHandler?(.sessions(sessions))
            }.store(in: &publishers)
    }
    
    private func handleSessionProposalEvents() {
        signAPI
            .sessionProposalPublisher
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] sessionProposal, context in
                guard let self else { return }
                
                self.eventHandler?(.proposeSession(sessionProposal))
            }.store(in: &publishers)
    }
    
    private func handleSessionDeletionEvents() {
        signAPI
            .sessionDeletePublisher
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] topic, reason in
                guard let self else { return }
                
                self.eventHandler?(
                    .deleteSession(
                        topic: topic,
                        reason: reason
                    )
                )
            }.store(in: &publishers)
    }
    
    private func handleSessionSettleEvents() {
        signAPI
            .sessionSettlePublisher
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] session in
                guard let self else { return }
            
                self.eventHandler?(.settleSession(session))
            }.store(in: &publishers)
    }
    
    private func handleSessionUpdateEvents() {
        signAPI
            .sessionUpdatePublisher
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] topic, namespaces in
                guard let self else { return }
                
                self.eventHandler?(
                    .updateSession(
                        topic: topic,
                        namespaces: namespaces
                    )
                )
            }.store(in: &publishers)
    }
    
    private func handleSessionExtensionEvents() {
        signAPI
            .sessionExtendPublisher
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] topic, date in
                guard let self else { return }
            
                self.eventHandler?(
                    .extendSession(
                        topic: topic,
                        date: date
                    )
                )
            }.store(in: &publishers)
    }
    
    private func handlePingEvents() {
        signAPI
            .pingResponsePublisher
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] ping in
                guard let self else { return }
                
                self.eventHandler?(.pingSession(ping))
            }.store(in: &publishers)
    }
    
    private func handleTransactionRequestEvents() {
        signAPI
            .sessionRequestPublisher
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] request, context in
                guard let self else { return }
                
                self.eventHandler?(.transactionRequest(request))
            }.store(in: &publishers)
    }
}

extension WalletConnectV2Protocol {
    func getPairing(for topic: String) -> Pairing? {
        return try? pairAPI.getPairing(for: topic)
    }
}

enum WalletConnectV2Event {
    case sessions([WalletConnectV2Session])
    case proposeSession(WalletConnectV2SessionProposal)
    case didDisconnectSession(WalletConnectV2Session)
    case didDisconnectSessionFail(
        session: WalletConnectV2Session,
        error: Error
    )
    case deleteSession(
        topic: WalletConnectTopic,
        reason: WalletConnectV2Reason
    )
    case settleSession(WalletConnectV2Session)
    case updateSession(
        topic: WalletConnectTopic,
        namespaces: SessionNamespaces
    )
    case extendSession(
        topic: WalletConnectTopic,
        date: Date
    )
    case pingSession(WalletConnectTopic)
    case didPingSessionFail(
        session: WalletConnectV2Session,
        error: Error
    )
    case transactionRequest(WalletConnectV2Request)
    case failure(Error)
}

typealias SessionNamespaces = [String: SessionNamespace]
typealias WalletConnectV2SessionNamespace = SessionNamespace
typealias WalletConnectV2SessionProposal = WalletConnectSign.Session.Proposal
typealias WalletConnectV2SessionRejectionReason = RejectionReason
typealias WalletConnectV2Session = WalletConnectSign.Session
typealias WalletConnectV2Request = WalletConnectSign.Request
typealias WalletConnectV2CodableResult = AnyCodable
typealias WalletConnectV2Reason = Reason
typealias WalletConnectV2Account = WalletConnectUtils.Account
