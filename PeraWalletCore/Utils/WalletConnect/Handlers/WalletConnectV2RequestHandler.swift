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

//   WalletConnectV2RequestHandler.swift

import Foundation

public final class WalletConnectV2RequestHandler {
    public weak var delegate: WalletConnectV2RequestHandlerDelegate?

    private let analytics: ALGAnalytics

    public init(analytics: ALGAnalytics) {
        self.analytics = analytics
    }

    public func canHandle(request: WalletConnectV2Request) -> Bool {
        return request.isArbitraryDataSignRequest ||
            request.isTransactionSignRequest
    }

    public func handle(request: WalletConnectV2Request) {
        handleRequest(request)
    }
}

extension WalletConnectV2RequestHandler {
    private func handleRequest(_ request: WalletConnectV2Request) {
        if request.isArbitraryDataSignRequest {
            handleArbitraryDataSignRequest(request)
            return
        }

        if request.isTransactionSignRequest {
            handleTransactionSignRequest(request)
            return
        }
    }
}

extension WalletConnectV2RequestHandler {
    private func handleArbitraryDataSignRequest(_ request: WalletConnectV2Request) {
        var arbitraryData: [WCArbitraryData] = []

        do {
            arbitraryData = try request.params.get([WCArbitraryData].self)
        } catch {
            delegate?.walletConnectRequestHandler(self, didInvalidateTransactionRequest: request)
            return
        }

        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }
            self.delegate?.walletConnectRequestHandler(
                self,
                shouldSign: arbitraryData,
                for: request
            )
        }
    }
}

extension WalletConnectV2RequestHandler {
    private func handleTransactionSignRequest(_ request: WalletConnectV2Request) {
        analytics.record(
            .wcTransactionRequestReceived(transactionRequest: request)
        )
        analytics.track(
            .wcTransactionRequestReceived(transactionRequest: request)
        )

        let params: WCTransactionSignRequestParams

        do {
            params = try request.params.get(WCTransactionSignRequestParams.self)
        } catch {
            delegate?.walletConnectRequestHandler(self, didInvalidateTransactionRequest: request)
            return
        }

        analytics.record(
            .wcTransactionRequestValidated(transactionRequest: request)
        )
        analytics.track(
            .wcTransactionRequestValidated(transactionRequest: request)
        )

        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }
            self.delegate?.walletConnectRequestHandler(
                self,
                shouldSign: params.transactions,
                for: request,
                with: params.transactionOption
            )
        }
    }
}

public protocol WalletConnectV2RequestHandlerDelegate: AnyObject {
    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectV2RequestHandler,
        shouldSign transactions: [WCTransaction],
        for request: WalletConnectV2Request,
        with transactionOption: WCTransactionOption?
    )
    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectV2RequestHandler,
        didInvalidateTransactionRequest request: WalletConnectV2Request
    )
    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectV2RequestHandler,
        shouldSign arbitraryData: [WCArbitraryData],
        for request: WalletConnectV2Request
    )
    func walletConnectRequestHandler(
        _ walletConnectRequestHandler: WalletConnectV2RequestHandler,
        didInvalidateArbitraryDataRequest request: WalletConnectV2Request
    )
}

fileprivate extension WalletConnectV2Request {
    var isArbitraryDataSignRequest: Bool {
        return method == WalletConnectMethod.arbitraryDataSign.rawValue
    }

    var isTransactionSignRequest: Bool {
        return method == WalletConnectMethod.transactionSign.rawValue
    }
}

fileprivate struct WCTransactionSignRequestParams: Codable {
    let transactions: [WCTransaction]
    let transactionOption: WCTransactionOption?

    init(from decoder: Decoder) throws {
        var values = try decoder.unkeyedContainer()
        self.transactions = try values.decode([WCTransaction].self)
        self.transactionOption = try? values.decodeIfPresent(WCTransactionOption.self)
    }
}
