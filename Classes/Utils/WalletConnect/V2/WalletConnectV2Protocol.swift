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
    
    private var publishers = [AnyCancellable]()
    
    /// Account address that is used for the test connection/transaction.
    private let accountAddress = "Z4M6DE4KEDC5SRSWCVR5YR6PPIOTAIZL32VAYWGN5QGRCVRYUQWUBNUVUA"
    
    /// Project id is from a mock app that I created.
    private let projectID = "06274a21f488344abb80fc50223631f8"
    
    /// Metadata that is directly copied from WalletConnect v1.
    private let appMetadata = AppMetadata(
        name: "Pera Wallet",
        description: "Pera Wallet: Simply the best Algorand wallet.",
        url: "https://perawallet.app/",
        icons: [
            "https://algorand-app.s3.amazonaws.com/app-icons/Pera-walletconnect-128.png",
            "https://algorand-app.s3.amazonaws.com/app-icons/Pera-walletconnect-192.png",
            "https://algorand-app.s3.amazonaws.com/app-icons/Pera-walletconnect-512.png"
        ]
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
        
        setupEvents()
    }
}

extension WalletConnectV2Protocol {
    func pair(with topic: String) {
        guard let uri = WalletConnectURI(string: topic) else { return }
        
        print("[WC2] - Pairing to: \(uri)")
        
        Task {
            do {
                try await pairAPI.pair(uri: uri)
            } catch {
                print("[WC2] - Pairing connect error: \(error)")
            }
        }
    }
    
    func isValidSession(_ uri: WalletConnectSessionText) -> Bool {
        return sessionValidator.isValidSession(uri)
    }
}

extension WalletConnectV2Protocol {
    func getSessions() -> [WalletConnectSign.Session] {
        return signAPI.getSessions()
    }
    
    private func approveSession(
        _ proposalId: String,
        namespaces: [String: SessionNamespace]
    ) {
        print("[WC2] - Approve Session: \(proposalId)")
        
        Task {
            do {
                try await signAPI.approve(
                    proposalId: proposalId,
                    namespaces: namespaces
                )
            } catch {
                print("[WC2] - Approve Session error: \(error)")
            }
        }
    }

    private func rejectSession(
        _ proposalId: String,
        reason: RejectionReason
    ) async {
        print("[WC2] - Reject Session: \(proposalId)")
        
        Task {
            do {
                try await signAPI.reject(
                    proposalId: proposalId,
                    reason: reason
                )
            } catch {
                print("[WC2] - Reject Session error: \(error)")
            }
        }
    }
    
    private func extendSession(_ session: WalletConnectSign.Session) {
        print("[WC2] - Extend Session: \(session.topic)")
        
        Task {
            do {
                try await signAPI.extend(topic: session.topic)
            } catch {
                print("[WC2] - Extend Session error: \(error)")
            }
        }
    }
    
    private func updateSession(
        _ session: WalletConnectSign.Session,
        namespaces: [String: SessionNamespace]
    ) {
        print("[WC2] - Update Session: \(session.topic)")
        
        Task {
            do {
                try await signAPI.update(
                    topic: session.topic,
                    namespaces: namespaces
                )
            } catch {
                print("[WC2] - Update Session error: \(error)")
            }
        }
    }
}

extension WalletConnectV2Protocol {
    private func approveTransactionRequest(
        _ request: Request,
        response: AnyCodable
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
                print("[WC2] - Approve Request Error: \(error.localizedDescription)")
            }
        }
    }

    private func rejectTransactionRequest(_ request: Request) {
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
                print("[WC2] - Reject Request Error: \(error.localizedDescription)")
            }
        }
    }
}

extension WalletConnectV2Protocol {
    private func setupEvents() {
        handleSessionEvents()
        handleSessionProposalEvents()
        handleSessionDeletionEvents()
        handleTransactionRequestEvents()
    }
    
    private func handleSessionEvents() {
        signAPI
            .sessionsPublisher
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] sessionProposal in
                guard let self else { return }
                
            }.store(in: &publishers)
    }
    
    private func handleSessionProposalEvents() {
        signAPI
            .sessionProposalPublisher
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] sessionProposal in
                guard let self else { return }
                
                self.eventHandler?(.session(sessionProposal))
                
                /* var sessionNamespaces = [String: SessionNamespace]()
                sessionProposal.requiredNamespaces.forEach {
                    let caip2Namespace = $0.key
                    let proposalNamespace = $0.value
                    guard let chains = proposalNamespace.chains else { return }
                    let accounts = Set(
                        chains.compactMap { chain in
                            WalletConnectUtils.Account(
                                "\(chain.absoluteString):\(self.accountAddress)"
                            )
                        }
                    )

                    let sessionNamespace = SessionNamespace(
                        accounts: accounts,
                        methods: proposalNamespace.methods,
                        events: proposalNamespace.events
                    )
                    sessionNamespaces[caip2Namespace] = sessionNamespace
                }
                
                self.approveSession(
                    sessionProposal.id,
                    namespaces: sessionNamespaces
                ) */
                
            }.store(in: &publishers)
    }
    
    private func handleSessionDeletionEvents() {
        // sessionSettlePublisher
        // sessionUpdatePublisher
        // sessionExtendPublisher
        // pingResponsePublisher
        signAPI
            .sessionDeletePublisher
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] _ in
                guard let self else { return }
                
            }.store(in: &publishers)
    }
    
    private func handleTransactionRequestEvents() {
        signAPI
            .sessionRequestPublisher
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] request in
                guard let self else { return }
                
                if let transactionRequests = try? request.params.get([[WCTransaction]].self) {
                    self.eventHandler?(.transactionRequest(transactionRequests))
                }
                /* guard let unparsedTransactionDetail = params2.first?.first?.unparsedTransactionDetail else { return }

                var error: NSError?
                
                if let signature = self.api.session.privateData(for: self.accountAddress) {
                    let signedTransaction = self.algorandSDK.sign(signature, with: unparsedTransactionDetail, error: &error)
                    self.approveTransactionRequest(request, response: AnyCodable([signedTransaction]))
                } */
                
            }.store(in: &publishers)
    }
}

enum WalletConnectV2Event {
    case session(WalletConnectSign.Session.Proposal)
    case transactionRequest([[WCTransaction]])
}
