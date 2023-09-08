// Copyright 2022 Pera Wallet, LDA
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
//   WalletConnectV1Protocol.swift

import Foundation
import MacaroonUtils
import UIKit
import WalletConnectSwift

class WalletConnectV1Protocol:
    WalletConnectProtocol,
    ServerDelegate {
    static var didReceiveSessionRequestNotification: Notification.Name {
        return .init(
            rawValue: "com.algorand.algorand.notification.walletConnectV1Protocol.didReceiveSessionRequest"
        )
    }
    
    static var sessionRequestPreferencesKey: String {
        return "walletConnector.preferences"
    }

    private lazy var walletConnectServer = WalletConnectServer(delegate: self)
    private lazy var sessionSource = WalletConnectSessionSource()
    private(set) var sessionValidator: WalletConnectSessionValidator

    var eventHandler: ((WalletConnectV1Event) -> Void)?
    weak var delegate: WalletConnectorDelegate?
    
    var isRegisteredToTheTransactionRequests = false

    private let api: ALGAPI
    private let pushToken: String?
    private let analytics: ALGAnalytics

    private var ongoingConnections: [String: Bool] = [:]
    private var preferences: WalletConnectSessionCreationPreferences?

    init(
        api: ALGAPI,
        pushToken: String?,
        analytics: ALGAnalytics
    ) {
        self.api = api
        self.pushToken = pushToken
        self.analytics = analytics
        self.sessionValidator = WalletConnectV1SessionValidator()
    }
}

extension WalletConnectV1Protocol {
    func isValidSession(_ uri: WalletConnectSessionText) -> Bool {
        return sessionValidator.isValidSession(uri)
    }
    
    func configureTransactionsIfNeeded() {
        if isRegisteredToTheTransactionRequests {
            return
        }
        
        isRegisteredToTheTransactionRequests = true
        
        clearExpiredSessionsIfNeeded()
        registerToWCTransactionRequests()
        reconnectToSavedSessionsIfPossible()
    }
    
    private func registerToWCTransactionRequests() {
        let wcRequestHandler = TransactionSignRequestHandler(analytics: analytics)
        if let rootViewController = UIApplication.shared.rootViewController() {
            wcRequestHandler.delegate = rootViewController
        }
        register(for: wcRequestHandler)
    }
}

extension WalletConnectV1Protocol {
    // Register the actions that WalletConnect is able to handle.
    private func register(for handler: WalletConnectRequestHandler) {
        register(handler)
    }

    /// <note>:
    /// `preferences` value repsents user preferences for specific wallet connection
    func connect(with preferences: WalletConnectSessionCreationPreferences) {
        self.preferences = preferences

        let session = preferences.session

        guard let url = WalletConnectURL(session) else {
            eventHandler?(
                .didFail(
                    .failedToCreateSession(
                        qr: session
                    )
                )
            )
            delegate?.walletConnector(self, didFailWith: .failedToCreateSession(qr: session))
            return
        }

        let key = url.absoluteString

        if ongoingConnections[key] != nil {
            return
        }

        do {
            ongoingConnections[key] = true
            try connect(to: url)
        } catch {
            ongoingConnections.removeValue(forKey: key)
            eventHandler?(
                .didFail(
                    .failedToConnect(
                        url: url
                    )
                )
            )
            delegate?.walletConnector(self, didFailWith: .failedToConnect(url: url))
        }
    }
    
    func updateSessionsWithRemovingAccount(_ account: Account) {
        allWalletConnectSessions.forEach {
            guard let sessionAccounts = $0.walletMeta?.accounts,
                  sessionAccounts.contains(account.address) else {
                return
            }
                                    
            if sessionAccounts.count == 1 {
                disconnectFromSession($0)
                return
            }
            
                        
            guard let sessionWalletInfo = $0.sessionBridgeValue.walletInfo else {
                return
            }
                        
            let newAccountsForSession = sessionWalletInfo.accounts.filter { oldSessionAccount in
                oldSessionAccount != account.address
            }

            let newSessionWaletInfo = createNewSessionWalletInfo(
                from: sessionWalletInfo,
                newAccounts: newAccountsForSession
            )
            
            do {
                try update(session: $0.sessionBridgeValue, with: newSessionWaletInfo)
                
                let newSession = createNewSession(
                    from: $0,
                    newSessionWalletInfo: newSessionWaletInfo
                )
                
                updateWalletConnectSession(newSession, with: $0.urlMeta)
            } catch {}
        }
    }
    
    private func createNewSessionWalletInfo(
        from oldWalletInfo: WalletConnectSessionWalletInfo,
        newAccounts: [String]
    ) -> WalletConnectSessionWalletInfo {
        return WalletConnectSessionWalletInfo(
            approved: oldWalletInfo.approved,
            accounts: newAccounts,
            chainId: oldWalletInfo.chainId,
            peerId: oldWalletInfo.peerId,
            peerMeta: oldWalletInfo.peerMeta
        )
    }
    
    private func createNewSession(
        from oldSession: WCSession,
        newSessionWalletInfo: WalletConnectSessionWalletInfo
    ) -> WCSession {
        return WCSession(
            urlMeta: oldSession.urlMeta,
            peerMeta: oldSession.peerMeta,
            walletMeta: WCWalletMeta(
                walletInfo: newSessionWalletInfo,
                dappInfo: oldSession.peerMeta.dappInfo
            ),
            date: oldSession.date
        )
    }

    func disconnectFromSession(_ session: WCSession) {
        do {
            try disconnect(from: session.sessionBridgeValue)
            removeFromSessions(session)
        } catch WalletConnectSwift.WalletConnect.WalletConnectError.tryingToDisconnectInactiveSession {
            eventHandler?(
                .didFail(
                    .failedToDisconnectInactiveSession(
                        session: session
                    )
                )
            )

            removeFromSessions(session)
            delegate?.walletConnector(self, didFailWith: .failedToDisconnectInactiveSession(session: session))
        } catch {
            eventHandler?(
                .didFail(
                    .failedToDisconnect(
                        session: session
                    )
                )
            )
            delegate?.walletConnector(self, didFailWith: .failedToDisconnect(session: session))
        }
    }
    
    private func disconnectFromSessionSilently(_ session: WCSession) {
        try? disconnect(from: session.sessionBridgeValue)
        removeFromSessions(session)
    }

    func disconnectFromAllSessions() {
        allWalletConnectSessions.forEach(disconnectFromSession)
    }

    private func reconnectToSavedSessionsIfPossible() {
        for session in allWalletConnectSessions {
            do {
                try reconnect(to: session.sessionBridgeValue)
            } catch {
                removeFromSessions(session)
            }
        }
    }
}

extension WalletConnectV1Protocol {
    private func addToSavedSessions(_ session: WCSession) {
        sessionSource.addWalletConnectSession(session)
    }

    private func removeFromSessions(_ session: WCSession) {
        sessionSource.removeWalletConnectSession(with: session.urlMeta)
    }

    var allWalletConnectSessions: [WCSession] {
        sessionSource.allWalletConnectSessions
    }

    func getWalletConnectSession(for topic: WalletConnectTopic) -> WCSession? {
        return sessionSource.getWalletConnectSession(for: topic)
    }
    
    func updateWalletConnectSession(_ session: WCSession, with url: WCURLMeta) {
        sessionSource.updateWalletConnectSession(session, with: url)
    }

    func resetAllSessions() {
        sessionSource.resetAllSessions()
    }

    func saveConnectedWCSession(_ session: WCSession) {
        if let sessionData = try? JSONEncoder().encode([session.urlMeta.topic: session]) {
            WCSessionHistory.create(
                entity: WCSessionHistory.entityName,
                with: [WCSessionHistory.DBKeys.sessionHistory.rawValue: sessionData]
            )
        }
    }
}

extension WalletConnectV1Protocol {
    func server(
        _ server: WalletConnectServer,
        shouldStart session: WalletConnectSession,
        completion: @escaping (WalletConnectSession.WalletInfo) -> Void
    ) {
        // Get user approval or rejection for the session
        eventHandler?(
            .shouldStart(
                session: session,
                preferences: preferences,
                completion: completion
            )
        )
        delegate?.walletConnector(self, shouldStart: session, with: preferences, then: completion)
    }

    func server(
        _ server: WalletConnectServer,
        didConnect session: WalletConnectSession
    ) {
        asyncMain(afterDuration: 0) { [weak self] in
            guard let self = self else {
                return
            }

            let connectedSession = session.toWCSession()
            let localSession = self.sessionSource.getWalletConnectSession(for: connectedSession.urlMeta.topic)
            
            if localSession == nil {
                self.addToSavedSessions(connectedSession)
            }

            /// <todo>
            /// Disabled supporting WC push notificataions for now 06.01.2023
//            self.subscribeForNotificationsIfNeeded(localSession ?? connectedSession)
            
            let key = session.url.absoluteString
            self.ongoingConnections.removeValue(forKey: key)
            self.eventHandler?(.didConnect(connectedSession))
            self.delegate?.walletConnector(self, didConnectTo: connectedSession, with: preferences)
        }
    }

    func server(
        _ server: WalletConnectServer,
        didDisconnect session: WalletConnectSession
    ) {
        asyncMain(afterDuration: 0) { [weak self] in
            guard let self = self else {
                return
            }

            let wcSession = session.toWCSession()
            self.removeFromSessions(wcSession)
            self.eventHandler?(.didDisconnect(wcSession))
            self.delegate?.walletConnector(self, didDisconnectFrom: wcSession)
        }
    }

    func server(
        _ server: WalletConnectServer,
        didFailToConnect url: WalletConnectURL
    ) {
        let key = url.absoluteString
        ongoingConnections.removeValue(forKey: key)
        eventHandler?(
            .didFail(
                .failedToConnect(
                    url: url
                )
            )
        )
        delegate?.walletConnector(self, didFailWith: .failedToConnect(url: url))
    }

    func server(
        _ server: WalletConnectServer,
        didUpdate session: WalletConnectSession
    ) { }
    
    func server(
        _ server: Server,
        didFailWith error: Error?,
        for url: WCURL
    ) {
        analytics.record(
            .wcTransactionRequestSDKError(error: error, url: url)
        )
        analytics.track(
            .wcTransactionRequestSDKError(error: error, url: url)
        )
    }
}

extension WalletConnectV1Protocol {
    private func subscribeForNotificationsIfNeeded(_ session: WCSession) {
        if session.isSubscribed {
            return
        }

        let user = api.session.authenticatedUser
        let deviceID = user?.getDeviceId(on: api.network)

        let draft = SubscribeToWalletConnectSessionDraft(
            deviceID: deviceID,
            wcSession: session,
            pushToken: pushToken
        )

        api.subscribeToWalletConnectSession(draft) {
            [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success:
                session.isSubscribed = true
                self.addToSavedSessions(session)
            default:
                break
            // The session is already saved before subscription call.
            // The failure means there is no change. So, it is not needed to handle.
            }
        }
    }
    
    /// <note
    /// The oldest sessions on the device should be disconnected and removed when the maximum session limit is exceeded.
    func clearExpiredSessionsIfNeeded() {
        let sessionLimit = WalletConnectSessionSource.sessionLimit
        
        guard let sessions = sessionSource.sessions.unwrap(where: { $0.count > sessionLimit }) else { return }
        
        let orderedSessions = sessions.values.sorted { $0.date > $1.date }
        let oldSessions = orderedSessions[sessionLimit...]
        
        oldSessions.forEach { session in
            disconnectFromSessionSilently(session)
        }
        
        eventHandler?(.didExceedMaximumSession)
        delegate?.walletConnectorDidExceededMaximumSessionLimit(self)
    }
}

extension WalletConnectV1Protocol {
    func isConnected(by url: WCURL) -> Bool {
        return walletConnectServer.isConnected(by: url)
    }

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
    
    func update(session: WalletConnectSession, with newWalletInfo: WalletConnectSessionWalletInfo) throws {
        try walletConnectServer.updateSession(session, with: newWalletInfo)
    }
    
    func signTransactionRequest(_ request: WalletConnectRequest, with signature: [Data?]) {
        if let signature = WalletConnectResponse.signature(signature, for: request) {
            walletConnectServer.send(signature)
        }
    }

    func rejectTransactionRequest(_ request: WalletConnectRequest, with error: WCTransactionErrorResponse) {
        if let rejection = WalletConnectResponse.rejection(request, with: error) {
            walletConnectServer.send(rejection)
        }
    }
}

extension WalletConnectV1Protocol {
    enum WCError {
        case failedToConnect(url: WalletConnectURL)
        case failedToCreateSession(qr: String)
        case failedToDisconnectInactiveSession(session: WCSession)
        case failedToDisconnect(session: WCSession)
    }
}

enum WalletConnectV1Event {
    case shouldStart(
        session: WalletConnectSession,
        preferences: WalletConnectSessionCreationPreferences?,
        completion: WalletConnectSessionConnectionCompletionHandler
    )
    case didConnect(WCSession)
    case didDisconnect(WCSession)
    case didFail(WalletConnectV1Protocol.WCError)
    case didExceedMaximumSession
}

protocol WalletConnectorDelegate: AnyObject {
    func walletConnector(
        _ walletConnector: WalletConnectV1Protocol,
        shouldStart session: WalletConnectSession,
        with preferences: WalletConnectSessionCreationPreferences?,
        then completion: @escaping WalletConnectSessionConnectionCompletionHandler
    )
    func walletConnector(
        _ walletConnector: WalletConnectV1Protocol,
        didConnectTo session: WCSession,
        with preferences: WalletConnectSessionCreationPreferences?
    )
    func walletConnector(
        _ walletConnector: WalletConnectV1Protocol,
        didDisconnectFrom session: WCSession
    )
    func walletConnector(
        _ walletConnector: WalletConnectV1Protocol,
        didFailWith error: WalletConnectV1Protocol.WCError
    )
    func walletConnectorDidExceededMaximumSessionLimit(_ walletConnector: WalletConnectV1Protocol)
}

extension WalletConnectorDelegate {
    func walletConnector(
        _ walletConnector: WalletConnectV1Protocol,
        shouldStart session: WalletConnectSession,
        with preferences: WalletConnectSessionCreationPreferences?,
        then completion: @escaping WalletConnectSessionConnectionCompletionHandler
    ) { }

    func walletConnector(
        _ walletConnector: WalletConnectV1Protocol,
        didConnectTo session: WCSession,
        with preferences: WalletConnectSessionCreationPreferences?
    ) { }

    func walletConnector(
        _ walletConnector: WalletConnectV1Protocol,
        didDisconnectFrom session: WCSession
    ) { }

    func walletConnector(
        _ walletConnector: WalletConnectV1Protocol,
        didFailWith error: WalletConnectV1Protocol.WCError
    ) { }
    
    func walletConnectorDidExceededMaximumSessionLimit(_ walletConnector: WalletConnectV1Protocol) { }
}

enum WalletConnectMethod: String {
    case transactionSign = "algo_signTxn"
}

typealias WalletConnectSession = WalletConnectSwift.Session
typealias WalletConnectURL = WCURL
typealias WalletConnectServer = WalletConnectSwift.Server
typealias WalletConnectRequest = WalletConnectSwift.Request
typealias WalletConnectResponse = WalletConnectSwift.Response
typealias WalletConnectSessionWalletInfo = WalletConnectSwift.Session.WalletInfo
typealias WalletConnectSessionConnectionCompletionHandler = (WalletConnectSessionWalletInfo) -> Void
typealias WalletConnectTopic = String
