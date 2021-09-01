//
//  HIPSessionConvertible.swift
//  Pods
//
//  Created by Karasuluoglu on 9.10.2020.
//

import Foundation

public protocol HIPSessionConvertible: Printable {
    associatedtype Credentials: HIPSessionCredentialsConvertible
    associatedtype AuthenticatedUser: HIPSessionAuthenticatedUser

    var credentials: Credentials? { get }
    var authenticatedUser: AuthenticatedUser? { get }

    func hasAuthorization() -> Bool
    func authorize(_ newCredentials: Credentials) throws
    func deauthorize() throws
    func hasAuthentication() -> Bool
    func authenticate(_ newAuthenticatedUser: AuthenticatedUser)
    func deauthenticate()
}

public protocol HIPSessionCredentialsConvertible: Model {
    var token: String { get }
}

public protocol HIPSessionAuthenticatedUser: Model { }

public protocol HIPSessionUpdatesPublisher: AnyObject {
    var delegations: [ObjectIdentifier: HIPSessionUpdatesDelegation] { get set }

    func add(delegate: HIPSessionUpdatesDelegate)
    func remove(delegate: HIPSessionUpdatesDelegate)
}

extension HIPSessionUpdatesPublisher {
    public func add(delegate: HIPSessionUpdatesDelegate) {
        let id = ObjectIdentifier(delegate)
        delegations[id] = HIPSessionUpdatesDelegation(delegate)
    }

    public func remove(delegate: HIPSessionUpdatesDelegate) {
        let id = ObjectIdentifier(delegate)
        delegations[id] = nil
    }

    public func removeAllDelegates() {
        delegations.removeAll()
    }

    public func notifyDelegates(_ notifier: (HIPSessionUpdatesDelegate) -> Void) {
        delegations.forEach {
            if let delegate = $0.value.delegate {
                notifier(delegate)
            } else {
                delegations[$0.key] = nil
            }
        }
    }
}

public protocol HIPSessionUpdatesDelegate: AnyObject {
    func sessionDidAuthorize<T: HIPSessionConvertible>(_ session: T)
    func sessionDidDeauthorize<T: HIPSessionConvertible>(_ session: T)
    func sessionDidAuthenticate<T: HIPSessionConvertible>(_ session: T)
    func sessionDidDeauthenticate<T: HIPSessionConvertible>(_ session: T)
}

extension HIPSessionUpdatesDelegate {
    public func sessionDidAuthorize<T: HIPSessionConvertible>(_ session: T) { }
    public func sessionDidDeauthorize<T: HIPSessionConvertible>(_ session: T) { }
    public func sessionDidAuthenticate<T: HIPSessionConvertible>(_ session: T) { }
    public func sessionDidDeauthenticate<T: HIPSessionConvertible>(_ session: T) { }
}

public class HIPSessionUpdatesDelegation {
    weak var delegate: HIPSessionUpdatesDelegate?

    init(_ delegate: HIPSessionUpdatesDelegate) {
        self.delegate = delegate
    }
}
