// Copyright 2023 Pera Wallet, LDA

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

final class WalletConnectV2RequestHandler {
    weak var delegate: WalletConnectV2RequestHandlerDelegate?

    func canHandle(request: WalletConnectV2Request) -> Bool {
        return
            request.isArbitraryDataSignRequest ||
            request.isTransactionSignRequest
    }

    func handle(request: WalletConnectV2Request) {
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
    /// <todo> Arbitrary Data
    private func handleArbitraryDataSignRequest(_ request: WalletConnectV2Request) {
        var arbitraryData: [WCArbitraryData] = []

//        for param in 0..<request.parameterCount {
//            if let data = try? request.parameter(of: WCArbitraryData.self, at: param) {
//                arbitraryData.append(data)
//            } else {
//                DispatchQueue.main.async {
//                    [weak self] in
//                    guard let self else { return }
//                    self.delegate?.walletConnectRequestHandler(self, didInvalidateArbitraryDataRequest: request)
//                }
//                return
//            }
//        }

        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }
            delegate?.walletConnectRequestHandler(
                self,
                shouldSign: arbitraryData,
                for: request
            )
        }
    }
}

extension WalletConnectV2RequestHandler {
    private func handleTransactionSignRequest(_ request: WalletConnectV2Request) {
        guard let transactions = try? request.params.get([[WCTransaction]].self) else {
            DispatchQueue.main.async {
                [weak self] in
                guard let self else { return }
                self.delegate?.walletConnectRequestHandler(self, didInvalidateTransactionRequest: request)
            }
            return
        }

        var transactionOption: WCTransactionOption? /// <todo> ???
//        if request.parameterCount > 1 {
//            transactionOption = try? request.parameter(of: WCTransactionOption.self, at: 1)
//        }

        DispatchQueue.main.async {
            [weak self] in
            guard let self else { return }
            self.delegate?.walletConnectRequestHandler(
                self,
                shouldSign: transactions.flatMap { $0 },
                for: request,
                with: transactionOption
            )
        }
    }
}

protocol WalletConnectV2RequestHandlerDelegate: AnyObject {
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
