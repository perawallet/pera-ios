//
//  HIPSession.swift
//  Magpie
//
//  Created by Karasuluoglu on 21.12.2019.
//

import Foundation

open class HIPSession<Credentials: HIPSessionCredentialsConvertible, AuthenticatedUser: HIPSessionAuthenticatedUser>: HIPSessionConvertible, HIPSessionUpdatesPublisher {
    public var delegations: [ObjectIdentifier : HIPSessionUpdatesDelegation] = [:]

    public private(set) var credentials: Credentials?
    public private(set) var authenticatedUser: AuthenticatedUser?

    public let keychain: HIPKeychainConvertible
    public let cache: HIPCacheConvertible?

    public init(
        keychain: HIPKeychainConvertible,
        cache: HIPCacheConvertible? = HIPCache()
    ) {
        self.keychain = keychain
        self.cache = cache

        autoAuthorize()
        autoAuthenticate()
    }

    open func hasAuthorization() -> Bool {
        return credentials != nil
    }

    open func authorize(_ credentials: Credentials) throws {
        self.credentials = credentials
        notifyDelegates { $0.sessionDidAuthorize(self) }

        try keychain.set(credentials, for: Keys.credentials)
    }

    open func autoAuthorize() {
        credentials = try? keychain.getModel(for: Keys.credentials)
    }

    open func deauthorize() throws {
        deauthenticate()

        credentials = nil
        notifyDelegates { $0.sessionDidDeauthorize(self) }

        try keychain.remove(for: Keys.credentials)
    }

    open func hasAuthentication() -> Bool {
        return authenticatedUser != nil
    }

    open func authenticate(_ authenticatedUser: AuthenticatedUser) {
        self.authenticatedUser = authenticatedUser
        notifyDelegates { $0.sessionDidAuthenticate(self) }

        cache?.set(model: authenticatedUser, for: Keys.authenticatedUser)
    }

    open func autoAuthenticate() {
        authenticatedUser = cache?.getModel(for: Keys.authenticatedUser)
    }

    open func deauthenticate() {
        authenticatedUser = nil
        notifyDelegates { $0.sessionDidDeauthenticate(self) }

        cache?.remove(for: Keys.authenticatedUser)
    }
}

extension HIPSession {
    public enum Keys: String, HIPKeychainKeyConvertible, HIPCacheKeyConvertible {
        case credentials = "session.credentials"
        case authenticatedUser = "session.authenticated_user"
    }
}

extension HIPSession {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return """
        \(credentials?.debugDescription ?? "<no credentials>")
        \(authenticatedUser?.debugDescription ?? "<no authenticated user>")
        """
    }
}

open class HIPSessionCredentials: HIPSessionCredentialsConvertible {
    public let token: String
}
