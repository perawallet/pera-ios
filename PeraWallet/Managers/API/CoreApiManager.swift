// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CoreApiManager.swift

import Foundation
import pera_wallet_core

final class CoreApiManager {
    
    enum ApiError: Error {
        case invalidBaseUrl(baseURL: String)
        case cantGenerateUrlFromComponents(components: URLComponents)
        case unableToEncodeBody(error: Error)
        case invalidHTTPStatusCode(code: Int)
        case responseError(error: Error)
        case cancelled
    }
    
    enum BaseURL {
        
        enum Network {
            case mainNet
            case testNet
        }
        
        enum Version {
            case v1
            case v2
        }
        
        case algod(network: Network)
        case indexer(network: Network)
        case mobile(network: Network, version: Version)
    }
    
    // MARK: - Properties
    
    var baseURL: BaseURL {
        didSet { cancelAllRequests() }
    }
    
    private let jsonDecoder: JSONDecoder = JSONDecoder()
    private let jsonEncoder: JSONEncoder = JSONEncoder()
    private let taskManager = CancellableTasksManager()
    
    // MARK: - Initialisers
    
    init(baseURL: BaseURL, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy, keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy) {
        self.baseURL = baseURL
        jsonDecoder.keyDecodingStrategy = keyDecodingStrategy
        jsonEncoder.keyEncodingStrategy = keyEncodingStrategy
    }
    
    // MARK: - Actions
    
    func perform<Request: Requestable>(request: Request) async throws(ApiError) -> Request.ResponseType {
        
        let url = try makeURL(request: request)
        let urlRequest = try makeUrlRequest(url: url, request: request)
        
        let task = Task {
            let result = try await URLSession.shared.data(for: urlRequest)
            try handle(response: result.1)
            return try jsonDecoder.decode(request.responseType, from: result.0)
        }
        
        let uuid = await taskManager.add(task: task)
        
        do {
            let value = try await task.value
            await taskManager.cancel(uuid: uuid)
            return value
        } catch let error as ApiError {
            await taskManager.cancel(uuid: uuid)
            throw error
        } catch let error as URLError {
            await taskManager.cancel(uuid: uuid)
            guard error.code == .cancelled else { throw ApiError.responseError(error: error) }
            throw ApiError.cancelled
        } catch {
            await taskManager.cancel(uuid: uuid)
            throw ApiError.responseError(error: error)
        }
    }
    
    private func cancelAllRequests() {
        Task {
            await taskManager.cancelAll()
        }
    }
    
    // MARK: - Factories
    
    private func makeURL(request: any Requestable) throws(ApiError) -> URL {
        
        guard var components = URLComponents(string: baseURL.rawUrl) else { throw .invalidBaseUrl(baseURL: baseURL.rawUrl) }
        components.path += request.path
        
        if request.method == .get || request.method == .delete, let requestWithQueryItems = request as? (any QueryRequestable) {
            components.queryItems = requestWithQueryItems.queryItems
        }
        
        guard let url = components.url else { throw .cantGenerateUrlFromComponents(components: components) }
        return url
    }
    
    private func makeUrlRequest(url: URL, request: any Requestable) throws(ApiError) -> URLRequest {
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = ["Content-Type": "application/json"]
        
        if request.method == .post || request.method == .put {
            do {
                let rawBody: Encodable
                
                if let requestWithBody = request as? (any BodyRequestable) {
                    rawBody = requestWithBody.body
                } else {
                    rawBody = request
                }
                
                urlRequest.httpBody = try jsonEncoder.encode(rawBody)
            } catch {
                throw .unableToEncodeBody(error: error)
            }
        }
        
        return urlRequest
    }
    
    // MARK: - Handlers
    
    private func handle(response: URLResponse) throws(ApiError) {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        guard 200...299 ~= httpResponse.statusCode else { throw .invalidHTTPStatusCode(code: httpResponse.statusCode) }
    }
}

extension CoreApiManager.BaseURL {
    
    var rawUrl: String {
        switch self {
        case let .algod(network):
            switch network {
            case .mainNet:
                return AppEnvironment.current.mainNetAlgodApi
            case .testNet:
                return AppEnvironment.current.testNetAlgodApi
            }
        case let .indexer(network):
            switch network {
            case .mainNet:
                return AppEnvironment.current.mainNetIndexerApi
            case .testNet:
                return AppEnvironment.current.testNetIndexerApi
            }
        case let .mobile(network, version):
            switch (network, version) {
            case (.mainNet, .v1):
                return AppEnvironment.current.mainNetMobileAPIV1.removeTrailingSlash()
            case (.mainNet, .v2):
                return AppEnvironment.current.mainNetMobileAPIV2.removeTrailingSlash()
            case (.testNet, .v1):
                return AppEnvironment.current.testNetMobileAPIV1.removeTrailingSlash()
            case (.testNet, .v2):
                return AppEnvironment.current.testNetMobileAPIV2.removeTrailingSlash()
            }
        }
    }
}

// FIXME: Currently, some of the URLs to the APIs have a trailing slash while others don't. Please remove unnecessary slashes at the end of the URLs, and delete this extension afterward.
private extension String {
    
    func removeTrailingSlash() -> String {
        guard hasSuffix("/") else { return self }
        return String(dropLast())
    }
}
