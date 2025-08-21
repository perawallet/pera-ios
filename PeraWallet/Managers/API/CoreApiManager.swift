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
    
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .kebabCase
        return decoder
    }()
    
    private let taskManager = CancellableTasksManager()
    
    // MARK: - Initialisers
    
    init(baseURL: BaseURL) {
        self.baseURL = baseURL
    }
    
    // MARK: - Actions
    
    func perform<Request: Requestable>(request: Request) async throws(ApiError) -> Request.ResponseType {
        
        guard var components = URLComponents(string: baseURL.rawUrl) else { throw .invalidBaseUrl(baseURL: baseURL.rawUrl) }
        components.path += request.path
        
        guard let url = components.url else { throw .cantGenerateUrlFromComponents(components: components) }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        
        let task = Task {
            let result = try await URLSession.shared.data(for: urlRequest)
            try handle(response: result.1)
            let response = try jsonDecoder.decode(request.responseType, from: result.0)
            return response
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
            guard error.code == .cancelled else { throw .responseError(error: error) }
            throw .cancelled
        } catch {
            await taskManager.cancel(uuid: uuid)
            throw .responseError(error: error)
        }
    }
    
    private func cancelAllRequests() {
        Task {
            await taskManager.cancelAll()
        }
    }
    
    // MARK: - Handlers
    
    private func handle(response: URLResponse) throws(ApiError) {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        guard httpResponse.statusCode == 200 else { throw .invalidHTTPStatusCode(code: httpResponse.statusCode) }
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
                return AppEnvironment.current.mainNetMobileAPIV1
            case (.mainNet, .v2):
                return AppEnvironment.current.mainNetMobileAPIV2
            case (.testNet, .v1):
                return AppEnvironment.current.testNetMobileAPIV1
            case (.testNet, .v2):
                return AppEnvironment.current.testNetMobileAPIV2
            }
        }
    }
}
