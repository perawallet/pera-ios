// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   RootViewController+WalletConnect.swift

import Foundation

// MARK: WalletConnectRequestHandlerDelegate

extension RootViewController: WalletConnectRequestHandlerDelegate {
    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectRequestHandler,
        shouldSign arbitraryData: [WCArbitraryData],
        for request: WalletConnectRequest
    ) {
        guard let session = findWCV1Session(for: request),
              canSignWCV1Request(for: request) else {
            return
        }

        addOngoingWCRequest(for: request.url.topic)

        let draft = WalletConnectArbitraryDataSignRequestDraft(
            request: WalletConnectRequestDraft(wcV1Request: request),
            arbitraryData: arbitraryData,
            session: WCSessionDraft(wcV1Session: session)
        )
        launchController.receive(deeplinkWithSource: .walletConnectArbitraryDataSignRequest(draft))
    }

    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectRequestHandler,
        didInvalidateArbitraryDataRequest request: WalletConnectRequest
    ) {
        let params = WalletConnectV1RejectTransactionRequestParams(
            v1Request: request,
            error: .invalidInput(.dataParse)
        )
        appConfiguration.peraConnect.rejectTransactionRequest(params)
    }

    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectRequestHandler,
        shouldSign transactions: [WCTransaction],
        for request: WalletConnectRequest,
        with transactionOption: WCTransactionOption?
    ) {
        guard let session = findWCV1Session(for: request),
              canSignWCV1Request(for: request) else {
            return
        }

        addOngoingWCRequest(for: request.url.topic)

        let draft = WalletConnectTransactionSignRequestDraft(
            request: WalletConnectRequestDraft(wcV1Request: request),
            transactions: transactions,
            option: transactionOption,
            session: WCSessionDraft(wcV1Session: session)
        )
        launchController.receive(deeplinkWithSource: .walletConnectTransactionSignRequest(draft))
    }

    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectRequestHandler,
        didInvalidateTransactionRequest request: WalletConnectRequest
    ) {
        let params = WalletConnectV1RejectTransactionRequestParams(
            v1Request: request,
            error: .invalidInput(.transactionParse)
        )
        appConfiguration.peraConnect.rejectTransactionRequest(params)
    }
    
    private func findWCV1Session(for request: WalletConnectRequest) -> WCSession? {
        guard let session = walletConnector.getWalletConnectSession(for: request.url.topic) else {
            let params = WalletConnectV1RejectTransactionRequestParams(
                v1Request: request,
                error: .invalidInput(.session)
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
            return nil
        }
        
        return session
    }
    
    private func canSignWCV1Request(
        for request: WalletConnectRequest
    ) -> Bool {
        let topic = request.url.topic

        if hasOngoingWCRequest(for: topic) {
            let params = WalletConnectV1RejectTransactionRequestParams(
                v1Request: request,
                error: .rejected(.alreadyDisplayed)
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
            return false
        }
        
        return true
    }
}

// MARK: PeraConnectObserver

extension RootViewController: PeraConnectObserver {
    func startObservingPeraConnectEvents() {
        appConfiguration.peraConnect.add(self)
    }

    func peraConnect(
        _ peraConnect: PeraConnect,
        didPublish event: PeraConnectEvent
    ) {
        switch event {
        case .transactionRequestV2(let request):
            if walletConnectV2RequestHandler.canHandle(request: request) {
                walletConnectV2RequestHandler.handle(request: request)
                return
            }

            let params = WalletConnectV2RejectTransactionRequestParams(
                error: .unsupportedMethods,
                v2Request: request
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
        default: break
        }
    }
}

// MARK: WalletConnectV2RequestHandlerDelegate

extension RootViewController: WalletConnectV2RequestHandlerDelegate {
    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectV2RequestHandler,
        shouldSign arbitraryData: [WCArbitraryData],
        for request: WalletConnectV2Request
    ) {
        guard let session = findWCV2Session(for: request),
              canSignWCV2Request(
                on: session,
                for: request
              ) else { 
            return
        }

        addOngoingWCRequest(for: request.topic)
        
        let draft = WalletConnectArbitraryDataSignRequestDraft(
            request: WalletConnectRequestDraft(wcV2Request: request),
            arbitraryData: arbitraryData,
            session: WCSessionDraft(wcV2Session: session)
        )
        launchController.receive(deeplinkWithSource: .walletConnectArbitraryDataSignRequest(draft))
    }
    
    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectV2RequestHandler,
        didInvalidateArbitraryDataRequest request: WalletConnectV2Request
    ) {
        let params = WalletConnectV2RejectTransactionRequestParams(
            error: .invalidInput(.transactionParse),
            v2Request: request
        )
        appConfiguration.peraConnect.rejectTransactionRequest(params)
    }

    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectV2RequestHandler,
        shouldSign transactions: [WCTransaction],
        for request: WalletConnectV2Request,
        with transactionOption: WCTransactionOption?
    ) {
        guard let session = findWCV2Session(for: request),
              canSignWCV2Request(
                on: session,
                for: request
              ) else {
            return
        }

        addOngoingWCRequest(for: request.topic)

        let draft = WalletConnectTransactionSignRequestDraft(
            request: WalletConnectRequestDraft(wcV2Request: request),
            transactions: transactions,
            session: WCSessionDraft(wcV2Session: session)
        )
        launchController.receive(deeplinkWithSource: .walletConnectTransactionSignRequest(draft))
    }

    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectV2RequestHandler,
        didInvalidateTransactionRequest request: WalletConnectV2Request
    ) {
        let params = WalletConnectV2RejectTransactionRequestParams(
            error: .invalidInput(.transactionParse),
            v2Request: request
        )
        appConfiguration.peraConnect.rejectTransactionRequest(params)
    }
    
    private func findWCV2Session(for request: WalletConnectV2Request) -> WalletConnectV2Session? {
        let wcV2Protocol =
            appConfiguration.peraConnect.walletConnectCoordinator.walletConnectProtocolResolver.walletConnectV2Protocol

        let sessions = wcV2Protocol.getSessions()
        let topic = request.topic
        guard let session = sessions.first(matching: (\WalletConnectV2Session.topic, topic)) else {
            let params = WalletConnectV2RejectTransactionRequestParams(
                error: .noSessionForTopic,
                v2Request: request
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
            return nil
        }
        
        return session
    }
    
    private func canSignWCV2Request(
        on session: WalletConnectV2Session,
        for request: WalletConnectV2Request
    ) -> Bool {
        let requiredNamespaces = session.requiredNamespaces[WalletConnectNamespaceKey.algorand]
        guard let requiredNamespaces,
              request.chainId.namespace == WalletConnectNamespaceKey.algorand else {
            let params = WalletConnectV2RejectTransactionRequestParams(
                error: .unsupportedNamespace,
                v2Request: request
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
            return false
        }

        let authorizedMethods = requiredNamespaces.methods
        let requestedMethod = request.method
        guard authorizedMethods.contains(requestedMethod) else {
            let params = WalletConnectV2RejectTransactionRequestParams(
                error: .unauthorizedMethod(requestedMethod),
                v2Request: request
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
            return false
        }

        let authorizedChains = requiredNamespaces.chains ?? []
        let requestedChain = request.chainId
        guard authorizedChains.contains(requestedChain) else {
            let network = ALGAPI.Network(blockchain: requestedChain)
            let networkTitle = network.unwrap(\.rawValue.capitalized) ?? requestedChain.reference
            let params = WalletConnectV2RejectTransactionRequestParams(
                error: .unauthorizedChain(networkTitle),
                v2Request: request
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
            return false
        }

        let requestedChainReference = requestedChain.reference
        guard
            requestedChainReference == algorandWalletConnectV2TestNetChainReference ||
            requestedChainReference == algorandWalletConnectV2MainNetChainReference
        else {
            let params = WalletConnectV2RejectTransactionRequestParams(
                error: .unsupportedChains,
                v2Request: request
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
            return false
        }

        let supportedMethods =  WalletConnectMethod.allCases.map(\.rawValue)
        guard supportedMethods.contains(requestedMethod) else {
            let params = WalletConnectV2RejectTransactionRequestParams(
                error: .unsupportedMethods,
                v2Request: request
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
            return false
        }

        if hasOngoingWCRequest(for: request.topic) {
            let params = WalletConnectV2RejectTransactionRequestParams(
                error: .rejected(.alreadyDisplayed),
                v2Request: request
            )
            appConfiguration.peraConnect.rejectTransactionRequest(params)
            return false
        }
        
        return true
    }
}

// MARK: WCMainArbitraryDataScreenDelegate

extension RootViewController: WCMainArbitraryDataScreenDelegate {
    func wcMainArbitraryDataScreen(
        _ wcMainArbitraryDataScreen: WCMainArbitraryDataScreen,
        didRejected request: WalletConnectRequestDraft
    ) {
        clearOngoingWCRequest(for: request)
        wcMainArbitraryDataScreen.dismissScreen()
    }

    func wcMainArbitraryDataScreen(
        _ wcMainArbitraryDataScreen: WCMainArbitraryDataScreen,
        didSigned request: WalletConnectRequestDraft,
        in session: WCSessionDraft
    ) {
        clearOngoingWCRequest(for: request)

        wcMainArbitraryDataScreen.dismissScreen {
            [weak self] in
            guard let self else { return }
            self.presentWCArbitraryDataSuccessMessageIfNeeded(for: session)
        }
    }

    private func presentWCArbitraryDataSuccessMessageIfNeeded(for session: WCSessionDraft) {
        if isInAppBrowserActive {
            return
        }
        
        let visibleScreen = findVisibleScreen()
        
        let dappName =
            session.wcV1Session?.peerMeta.name ??
            session.wcV2Session?.peer.name ??
            .empty
        let configurator = BottomWarningViewConfigurator(
            image: "icon-approval-check".uiImage,
            title: "wc-arbitrary-data-request-signed-warning-title".localized,
            description: .plain(
                "wc-arbitrary-data-request-signed-warning-message".localized(params: dappName, dappName)
            ),
            primaryActionButtonTitle: nil,
            secondaryActionButtonTitle: "title-close".localized
        )
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)

        transition.perform(
            .bottomWarning(configurator: configurator),
            by: .presentWithoutNavigationController
        )

        self.wcArbitraryDataSuccessTransition = transition
    }
}

// MARK: WCMainTransactionScreenDelegate

extension RootViewController: WCMainTransactionScreenDelegate {
    func wcMainTransactionScreen(
        _ wcMainTransactionScreen: WCMainTransactionScreen,
        didSigned request: WalletConnectRequestDraft,
        in session: WCSessionDraft
    ) {
        clearOngoingWCRequest(for: session)
        
        wcMainTransactionScreen.dismissScreen {
            [weak self] in
            guard let self else { return }
            self.openWCTransactionSignSuccessfulIfNeeded(session)
        }
    }
    
    func wcMainTransactionScreen(
        _ wcMainTransactionScreen: WCMainTransactionScreen,
        didRejected request: WalletConnectRequestDraft
    ) {
        clearOngoingWCRequest(for: request)
        wcMainTransactionScreen.dismissScreen()
    }
    
    private func openWCTransactionSignSuccessfulIfNeeded(_ draft: WCSessionDraft) {
        if isInAppBrowserActive {
            return
        }
        
        let visibleScreen = findVisibleScreen()
        
        let transition = BottomSheetTransition(presentingViewController: visibleScreen)
        
        let eventHandler: WCTransactionSignSuccessfulSheet.EventHandler = {
            [weak visibleScreen] event in
            guard let visibleScreen else { return }
            switch event {
            case .didClose:
                visibleScreen.presentedViewController?.dismiss(animated: true)
            }
        }
        
        transition.perform(
            .wcTransactionSignSuccessful(
                draft: draft,
                eventHandler: eventHandler
            ),
            by: .presentWithoutNavigationController
        )
        
        transitionToWCTransactionSignSuccessful = transition
    }
}

// MARK: Helpers

extension RootViewController {
    var walletConnector: WalletConnectV1Protocol {
        return appConfiguration.walletConnector
    }
    
    private func hasOngoingWCRequest(for topic: WalletConnectTopic) -> Bool {
        return sessionsForOngoingWCRequests[topic] != nil
    }

    private func addOngoingWCRequest(for topic: WalletConnectTopic) {
        sessionsForOngoingWCRequests[topic] = true
    }

    private func clearOngoingWCRequest(for session: WCSessionDraft) {
        let topic =
            session.wcV1Session?.urlMeta.topic ??
            session.wcV2Session?.topic
        guard let topic else { return }
        sessionsForOngoingWCRequests[topic] = nil
    }

    private func clearOngoingWCRequest(for request: WalletConnectRequestDraft) {
        let topic =
            request.wcV1Request?.url.topic ??
            request.wcV2Request?.topic
        guard let topic else { return }
        sessionsForOngoingWCRequests[topic] = nil
    }
}

private extension WalletConnectRequest {
    func isSameTransactionRequest(with request: WalletConnectRequest) -> Bool {
        if let firstId = id as? Int,
           let secondId = request.id as? Int {
            return firstId == secondId
        }

        if let firstId = id as? String,
           let secondId = request.id as? String {
            return firstId == secondId
        }

        if let firstId = id as? Double,
           let secondId = request.id as? Double {
            return firstId == secondId
        }

        return false
    }
}
