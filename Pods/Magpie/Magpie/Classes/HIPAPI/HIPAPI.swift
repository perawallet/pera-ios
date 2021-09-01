//
//  HIPAPI.swift
//  Magpie
//
//  Created by Karasuluoglu on 21.12.2019.
//

import Foundation

open class HIPAPI<Session: HIPSessionConvertible>: API {
    public let session: Session

    public required init(
        session: Session,
        base: String,
        networking: Networking = AlamofireNetworking(),
        interceptor: APIInterceptor? = nil,
        networkMonitor: NetworkMonitor? = nil
    ) {
        self.session = session
        super.init(
            base: base,
            networking: networking,
            interceptor: interceptor ?? HIPAPIInterceptor(session: session),
            networkMonitor: networkMonitor
        )
    }

    open func authorize(_ credentials: Session.Credentials) throws {
        try session.authorize(credentials)
    }

    open func deauthorize() throws {
        try session.deauthorize()
    }

    open func authenticate(_ authenticatedUser: Session.AuthenticatedUser) {
        session.authenticate(authenticatedUser)
    }

    open func deauthenticate() {
        session.deauthenticate()
    }
}
