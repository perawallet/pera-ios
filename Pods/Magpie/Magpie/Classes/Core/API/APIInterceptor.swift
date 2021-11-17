//
//  APIInterceptor.swift
//  Magpie
//
//  Created by Karasuluoglu on 19.12.2019.
//

import Foundation

public protocol APIInterceptor: Printable {
    func intercept(_ endpoint: EndpointOperatable)
    /// <note> It intercepts the response before forwarding to the completion handler. If true is returned,
    /// then the completion handler won't be notified with the response.
    func intercept(_ response: Response, for endpoint: EndpointOperatable) -> Bool
}

extension APIInterceptor {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return "Interceptor of \(type(of: self))"
    }
}
