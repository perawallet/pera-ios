//
//  HIPError.swift
//  Magpie
//
//  Created by Karasuluoglu on 29.07.2020.
//

import Foundation

public enum HIPNetworkError: Error {
    case client(HTTPError, HIPAPIError?)
    case server(HTTPError)
    case connection(ConnectionError)
    case unexpected(APIError)

    public init(
        apiError: APIError,
        apiErrorDetail: HIPAPIError? = nil
    ) {
        if let httpError = apiError as? HTTPError {
            if httpError.isClient {
                self = .client(httpError, apiErrorDetail)
                return
            }
            if httpError.isServer {
                self = .server(httpError)
                return
            }
        }
        if let connectionError = apiError as? ConnectionError {
            self = .connection(connectionError)
            return
        }
        self = .unexpected(apiError)
    }
}

extension HIPNetworkError: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        switch self {
        case .client(let httpError, let apiErrorDetail):
            return """
            Client
            \(httpError.debugDescription)
            \(apiErrorDetail.debugDescription)
            """
        case .server(let httpError):
            return """
            Server
            \(httpError.debugDescription)
            """
        case .connection(let connectionError):
            return """
            Connection
            \(connectionError.debugDescription)
            """
        case .unexpected(let apiError):
            return """
            Unexpected
            \(apiError.debugDescription)
            """
        }
    }
}

public enum HIPError<InAppError: Error>: Error {
    case inapp(InAppError)
    case network(HIPNetworkError)

    public init(
        apiError: APIError,
        apiErrorDetail: HIPAPIError? = nil
    ) {
        self = .network(
            HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
        )
    }
}

extension HIPError: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        switch self {
        case .inapp(let inappError):
            return """
            In-App
            \(inappError)
            """
        case .network(let networkError):
            return """
            Network
            \(networkError.debugDescription)
            """
        }
    }
}
