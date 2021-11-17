//
//  API.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 5.10.2018.
//

import Foundation

public protocol APIError: Error, Printable {
    var responseData: Data? { get }
}

extension APIError {
    public var responseData: Data? {
        return nil
    }
}

extension APIError {
    public var isHttpBadRequest: Bool {
        return (self as? HTTPError)?.isBadRequest ?? false
    }
    public var isHttpUnauthorized: Bool {
        return (self as? HTTPError)?.isUnauthorized ?? false
    }
    public var isHttpForbidden: Bool {
        return (self as? HTTPError)?.isForbidden ?? false
    }
    public var isHttpNotFound: Bool {
        return (self as? HTTPError)?.isNotFound ?? false
    }
    public var isClient: Bool {
        return (self as? HTTPError)?.isClient ?? false
    }
    public var isServer: Bool {
        return (self as? HTTPError)?.isServer ?? false
    }
    public var isNotConnectedToInternet: Bool {
        return (self as? ConnectionError)?.isNotConnectedToInternet ?? false
    }
    public var isCancelled: Bool {
        return (self as? ConnectionError)?.isCancelled ?? false
    }

    public func isHttp(_ statusCode: Int) -> Bool {
        return (self as? HTTPError) == HTTPError(statusCode: statusCode, responseData: nil)
    }
}

extension APIError {
    public var localizedDescription: String {
        return description
    }
}

public struct RequestEncodingError: APIError {
    public let reason: Reason

    public init(reason: Reason) {
        self.reason = reason
    }
}

extension RequestEncodingError {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        switch reason {
        case .emptyOrInvalidURL:
            return "Invalid URL"
        case .invalidURLQueryEncoding(let key):
            return "Invalid query item for \(key)"
        case .invalidJSONBodyEncoding(let underlyingError):
            return "Invalid json body encoding:\n\(underlyingError.localizedDescription)"
        case .invalidFormURLBodyEncoding(let key):
            return "Invalid form-url-encoded body param for \(key)"
        }
    }
}

extension RequestEncodingError {
    public enum Reason: Error {
        case emptyOrInvalidURL
        case invalidURLQueryEncoding(key: String)
        case invalidJSONBodyEncoding(underlyingError: Error)
        case invalidFormURLBodyEncoding(key: String)
    }
}

public struct EndpointOperationError: APIError {
    public let reason: Reason

    init(reason: Reason) {
        self.reason = reason
    }
}

extension EndpointOperationError {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        switch reason {
        case .retryBeforeSent:
            return "'retry()' operation can be available after calling 'send()'"
        }
    }
}

extension EndpointOperationError {
    public enum Reason {
        case retryBeforeSent
    }
}

public struct ResponseSerializationError: APIError {
    public let responseData: Data?
    public let reason: Reason

    public init(
        responseData: Data?,
        reason: Reason
    ) {
        self.responseData = responseData
        self.reason = reason
    }
}

extension ResponseSerializationError {
    /// <mark> CustomStringConvertible
    public var description: String {
        switch reason {
        case .corruptedData:
            return "Corrupted data"
        case .jsonSerializationFailed:
            return "JSON serialization failed"
        }
    }
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        return "\(description)\n\(responseData.absoluteUtf8Description)"
    }
}

extension ResponseSerializationError {
    public enum Reason {
        case corruptedData
        case jsonSerializationFailed(underlyingError: Error)
    }
}

public struct HTTPError: APIError, ExpressibleByIntegerLiteral, Equatable {
    public let statusCode: Int
    public let responseData: Data?
    public let reason: Reason

    public init(
        statusCode: Int,
        responseData: Data? = nil,
        underlyingError: Error? = nil
    ) {
        self.statusCode = statusCode
        self.responseData = responseData

        switch statusCode {
        case 300..<400:
            reason = .redirection(underlyingError: underlyingError)
        case 400:
            reason = .badRequest
        case 401:
            reason = .unauthorized
        case 403:
            reason = .forbidden
        case 404:
            reason = .notFound
        case 400..<500:
            reason = .client(underlyingError: underlyingError)
        case 501:
            reason = .notImplemented
        case 503:
            reason = .serviceUnavailable
        case 500..<600:
            reason = .server(underlyingError: underlyingError)
        default:
            reason = .unknown(underlyingError: underlyingError)
        }
    }

    /// <mark> ExpressibleByIntegerLiteral
    public init(integerLiteral value: Int) {
        self.init(statusCode: value, responseData: nil)
    }

    /// <mark> Equatable
    public static func == (lhs: HTTPError, rhs: HTTPError) -> Bool {
        return lhs.statusCode == rhs.statusCode
    }
}

extension HTTPError {
    public var isBadRequest: Bool {
        switch self.reason {
        case .badRequest:
            return true
        default:
            return false
        }
    }
    public var isUnauthorized: Bool {
        switch self.reason {
        case .unauthorized:
            return true
        default:
            return false
        }
    }
    public var isForbidden: Bool {
        switch self.reason {
        case .forbidden:
            return true
        default:
            return false
        }
    }
    public var isNotFound: Bool {
        switch self.reason {
        case .notFound:
            return true
        default:
            return false
        }
    }
    public var isClient: Bool {
        switch self.reason {
        case .badRequest,
             .unauthorized,
             .forbidden,
             .notFound,
             .client:
            return true
        default:
            return false
        }
    }
    public var isServer: Bool {
        switch self.reason {
        case .notImplemented,
             .serviceUnavailable,
             .server:
            return true
        default:
            return false
        }
    }
}

extension HTTPError {
    /// <mark> CustomStringConvertible
    public var description: String {
        switch reason {
        case .badRequest:
            return "400 Bad Request"
        case .unauthorized:
            return "401 Unauthorized"
        case .forbidden:
            return "403 Forbidden"
        case .notFound:
            return "404 Not found"
        case .notImplemented:
            return "501 Not implemented"
        case .serviceUnavailable:
            return "503 Service unavailable"
        default:
            return "Status: \(statusCode)"
        }
    }
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        switch reason {
        case .redirection(let underlyingError),
             .client(let underlyingError),
             .server(let underlyingError),
             .unknown(let underlyingError):
            return """
            \(description)
            \(underlyingError?.localizedDescription ?? "nil")
            \(responseData.absoluteUtf8Description)
            """
        default:
            return "\(description)\n\(responseData.absoluteUtf8Description)"
        }
    }
}

extension HTTPError {
    public enum Reason {
        case redirection(underlyingError: Error?) /// <note> 3xx
        case badRequest /// <note> 400
        case unauthorized /// <note> 401
        case forbidden /// <note> 403
        case notFound /// <note> 404
        case client(underlyingError: Error?) /// <note> 4xx
        case notImplemented /// <note> 501
        case serviceUnavailable /// <note> 503
        case server(underlyingError: Error?) /// <note> 5xx
        case unknown(underlyingError: Error?)
    }
}

public struct ConnectionError: APIError {
    public let reason: Reason
    public let underlyingError: URLError?

    public init(reason: Reason) {
        self.reason = reason
        self.underlyingError = nil
    }

    public init(urlError: URLError) {
        underlyingError = urlError

        switch urlError.code {
        case .timedOut,
             .cannotFindHost,
             .cannotConnectToHost,
             .networkConnectionLost,
             .dnsLookupFailed,
             .notConnectedToInternet,
             .internationalRoamingOff,
             .callIsActive,
             .dataNotAllowed:
            reason = .notConnectedToInternet(urlError.code)
        case .cancelled:
            reason = .cancelled
        default:
            reason = .unexpected(urlError.code)
        }
    }
}

extension ConnectionError {
    public var isNotConnectedToInternet: Bool {
        switch reason {
        case .notConnectedToInternet:
            return true
        default:
            return false
        }
    }
    public var isCancelled: Bool {
        switch reason {
        case .cancelled:
            return true
        default:
            return false
        }
    }
}

extension ConnectionError {
    /// <mark> CustomStringConvertible
    public var description: String {
        switch reason {
        case .notConnectedToInternet:
            return "Not connected to internet"
        case .cancelled:
            return "Cancelled"
        case .unexpected(let code):
            return "Unexpected \(code)"
        }
    }
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        if let underlyingError = underlyingError {
            return "\(description)\n\(underlyingError.localizedDescription)"
        }
        return description
    }
}

extension ConnectionError {
    public enum Reason {
        case notConnectedToInternet(URLError.Code)
        case cancelled
        case unexpected(URLError.Code)
    }
}

public struct UnexpectedError: APIError {
    public let responseData: Data?
    public let underlyingError: Error?

    public init(
        responseData: Data?,
        underlyingError: Error?
    ) {
        self.responseData = responseData
        self.underlyingError = underlyingError
    }
}

extension UnexpectedError {
    /// <mark> CustomStringConvertible
    public var description: String {
        return "Unexpected"
    }

    public var debugDescription: String {
        return "\(description)\n\(underlyingError?.localizedDescription ?? "<nil>")"
    }
}
