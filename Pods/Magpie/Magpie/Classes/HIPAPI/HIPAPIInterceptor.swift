//
//  HIPAPIInterceptor.swift
//  Magpie
//
//  Created by Karasuluoglu on 21.12.2019.
//

import Foundation

open class HIPAPIInterceptor<Session: HIPSessionConvertible>: HIPAPISessionInterceptor {
    public lazy var application = HIPApplication()
    public lazy var device = HIPDevice()

    public let session: Session

    public required init(session: Session) {
        self.session = session
    }

    open func intercept(_ endpoint: EndpointOperatable) {
        /// <note> HTTP
        endpoint.setAdditionalHeader(AcceptHeader.json(), .setIfNotExists)
        endpoint.setAdditionalHeader(AcceptEncodingHeader.gzip(), .setIfNotExists)
        endpoint.setAdditionalHeader(ContentTypeHeader.json(), .setIfNotExists)

        /// <note> Hipo
        endpoint.setAdditionalHeader(AppNameHeader(application), .alwaysOverride)
        endpoint.setAdditionalHeader(AppPackageNameHeader(application), .alwaysOverride)
        endpoint.setAdditionalHeader(AppVersionHeader(application), .alwaysOverride)
        endpoint.setAdditionalHeader(ClientTypeHeader(device), .alwaysOverride)
        endpoint.setAdditionalHeader(DeviceOSVersionHeader(device), .alwaysOverride)
        endpoint.setAdditionalHeader(DeviceModelHeader(device), .alwaysOverride)

        /// <note> Authorization
        if let credentials = session.credentials {
            endpoint.setAdditionalHeader(AuthorizationHeader.token(credentials.token), .alwaysOverride)
        }
    }

    open func intercept(_ response: Response, for endpoint: EndpointOperatable) -> Bool {
        return false
    }
}

extension HIPAPIInterceptor {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return session.credentials?.debugDescription ?? "no interception occured"
    }
}

public protocol HIPAPISessionInterceptor: APIInterceptor {
    associatedtype Session: HIPSessionConvertible

    var session: Session { get }
}
