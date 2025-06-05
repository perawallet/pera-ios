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

//   WCArbitraryDataSigner.swift

import Foundation
import MagpieHipo

final class WCArbitraryDataSigner {
    weak var delegate: WCArbitraryDataSignerDelegate?

    private let api: ALGAPI
    private let analytics: ALGAnalytics
    private let hdWalletStorage: HDWalletStorable

    init(
        api: ALGAPI,
        analytics: ALGAnalytics,
        hdWalletStorage: HDWalletStorable
    ) {
        self.api = api
        self.analytics = analytics
        self.hdWalletStorage = hdWalletStorage
    }

    func signData(
        _ data: WCArbitraryData,
        for account: Account
    ) {
        if account.hdWalletAddressDetail != nil {
            signArbitraryDataForHDWalletAccount(
                data,
                for: account
            )
            return
        }
        
        if let signature = api.session.privateData(for: account.address) {
            let signer = SDKArbitraryDataSigner()
            signer.eventHandler = {
                [weak self] event in
                guard let self else { return }
                
                switch event {
                case .didFailedSigning(let error):
                    delegate?.wcArbitraryDataSigner(
                        self,
                        didFailedWith: .api(error: error)
                    )
                }
            }
            sign(
                signature,
                signer: signer,
                for: data
            )
        }
    }
    
    private func signArbitraryDataForHDWalletAccount(
        _ arbitraryData: WCArbitraryData,
        for account: Account
    ) {
        guard let hdWalletAddressDetail = account.hdWalletAddressDetail,
              let data = arbitraryData.data else {
            delegate?.wcArbitraryDataSigner(
                self,
                didFailedWith: .missingData
            )
            return
        }
        
        do {
            guard let seed = try hdWalletStorage.wallet(id: hdWalletAddressDetail.walletId) else {
                return
            }
            
            let signer = HDWalletTransactionSigner(wallet: seed)
            let signedData = try signer.signTransaction(
                prefixedData(data),
                with: hdWalletAddressDetail
            )
                    
            delegate?.wcArbitraryDataSigner(
                self,
                didSign: arbitraryData,
                signedData: signedData
            )
        } catch {
            delegate?.wcArbitraryDataSigner(
                self,
                didFailedWith: .missingData
            )
        }
    }
    
    private func prefixedData(_ data: Data) -> Data {
        guard let prefix = "MX".data(using: .utf8) else {
            fatalError("Should never happen")
        }
        return prefix + data
    }
}

extension WCArbitraryDataSigner {
    private func sign(
        _ signature: Data?,
        signer: TransactionSignable,
        for data: WCArbitraryData
    ) {
        guard let unsignedData = data.data else {
            delegate?.wcArbitraryDataSigner(self, didFailedWith: .missingData)
            return
        }

        guard let signedData = signer.sign(unsignedData, with: signature) else {
            return
        }

        delegate?.wcArbitraryDataSigner(self, didSign: data, signedData: signedData)
    }
}

extension WCArbitraryDataSigner {
    enum WCSignError: Error {
        case api(error: HIPTransactionError)
        case missingData
    }
}

protocol WCArbitraryDataSignerDelegate: AnyObject {
    func wcArbitraryDataSigner(
        _ wcArbitraryDataSigner: WCArbitraryDataSigner,
        didSign data: WCArbitraryData,
        signedData: Data
    )
    func wcArbitraryDataSigner(
        _ wcArbitraryDataSigner: WCArbitraryDataSigner,
        didFailedWith error: WCArbitraryDataSigner.WCSignError
    )
}
