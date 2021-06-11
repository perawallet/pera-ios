// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   TransactionSignRequestHandler.swift

import WalletConnectSwift

class TransactionSignRequestHandler: WalletConnectRequestHandler {

    override func canHandle(request: WalletConnectRequest) -> Bool {
        return request.method == WalletConnectMethod.transactionSign.rawValue
    }

    override func handle(request: WalletConnectRequest) {
        do {
            // Just a basic implementation, will be updated later with the Signing Flow
            let transaction = try request.parameter(of: WalletConnectTransaction.self, at: 0)
            delegate?.walletConnectRequestHandler(self, shouldSign: transaction)
        } catch {
            delegate?.walletConnectRequestHandler(self, didInvalidate: request)
        }
    }
}

// Will be updated later with the Signing Flow
class WalletConnectTransaction: Codable {

}
