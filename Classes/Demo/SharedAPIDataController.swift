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
//   SharedAPIDataController.swift


import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo

final class SharedAPIDataController: SharedDataController {
    @Atomic(identifier: "currency")
    private(set) var currency: CurrencyHandle = .idle
    private(set) var accountCollection: AccountCollection = []
    private(set) var assetDetailCollection: AssetDetailCollection = []
    
    private lazy var blockProcessor = createBlockProcessor()
    private lazy var blockProcessorEventQueue =
        DispatchQueue(label: "com.algorand.queue.blockProcessor.events")
    
    private let session: Session
    private let api: ALGAPI
    
    init(
        session: Session,
        api: ALGAPI
    ) {
        self.session = session
        self.api = api
    }
    
    func startPolling() {
        blockProcessor.start()
    }
    
    func stopPolling() {
        blockProcessor.stop()
    }
}

extension SharedAPIDataController {
    private func createBlockProcessor() -> BlockProcessor {
        let request: ALGBlockProcessor.BlockRequest = { [unowned self] in
            var request = ALGBlockRequest()
            request.localAccounts = self.session.authenticatedUser?.accounts ?? []
            request.cachedAccounts = self.accountCollection
            request.cachedAssetDetails = self.assetDetailCollection
            request.localCurrencyId = self.session.preferredCurrency
            request.cachedCurrency = self.currency
            return request
        }
        let cycle = ALGBlockCycle(api: api)
        let processor = ALGBlockProcessor(blockRequest: request, blockCycle: cycle, api: api)
        
        processor.notify(queue: blockProcessorEventQueue) {
            [weak self] event in
            guard let self = self else { return }
            
            print("Event: \(event)")
            
            switch event {
            case .willStart:
                self.blockProcessorWillStart()
            case .willFetchCurrency:
                self.blockProcessorWillFetchCurrency()
            case .didFetchCurrency(let currency):
                self.blockProcessorDidFetchCurrency(currency)
            case .didFailToFetchCurrency(let error):
                self.blockProcessorDidFailToFetchCurrency(error)
            case .willFetchAccount(let localAccount):
                self.blockProcessorWillFetchAccount(localAccount)
            case .didFetchAccount(let account):
                self.blockProcessorDidFetchAccount(account)
            case .didFailToFetchAccount(let localAccount, let error):
                self.blockProcessorDidFailToFetchAccount(
                    localAccount,
                    error
                )
            case .willFetchAssetDetails(let account):
                self.blockProcessorWillFetchAssetDetails(for: account)
            case .didFetchAssetDetails(let account, let assetDetails):
                self.blockProcessorDidFetchAssetDetails(
                    assetDetails,
                    for: account
                )
            case .didFailToFetchAssetDetails(let account, let error):
                self.blockProcessorDidFailToFetchAssetDetails(
                    error,
                    for: account
                )
            case .didFinish:
                self.blockProcessorDidFinish()
            }
        }
        
        return processor
    }
    
    private func blockProcessorWillStart() {}
    
    private func blockProcessorWillFetchCurrency() {
        if let currencyValue = currency.value {
            $currency.modify { $0 = .refreshing(currencyValue) }
        } else {
            $currency.modify { $0 = .loading }
        }
    }
    
    private func blockProcessorDidFetchCurrency(
        _ currencyValue: Currency
    ) {
        $currency.modify { $0 = .ready(currency: currencyValue, lastUpdateDate: Date()) }
    }
    
    private func blockProcessorDidFailToFetchCurrency(
        _ error: HIPNetworkError<NoAPIModel>
    ) {
        if !currency.isAvailable {
            $currency.modify { $0 = .fault(error) }
        }
    }
    
    private func blockProcessorWillFetchAccount(
        _ localAccount: AccountInformation
    ) {
        let address = localAccount.address

        if let cachedAccount = accountCollection[address],
           cachedAccount.canRefresh() {
            accountCollection[address] =
                AccountHandle(account: cachedAccount.account, status: .refreshing)
        } else {
            accountCollection[address] =
                AccountHandle(localAccount: localAccount, status: .loading)
        }
    }
    
    private func blockProcessorDidFetchAccount(
        _ account: Account
    ) {
        accountCollection[account.address] = AccountHandle(account: account, status: .upToDate)
    }
    
    private func blockProcessorDidFailToFetchAccount(
        _ localAccount: AccountInformation,
        _ error: HIPNetworkError<NoAPIModel>
    ) {
        let address = localAccount.address
        
        if let cachedAccount = accountCollection[address],
           cachedAccount.status == .refreshing {
            accountCollection[address] =
                AccountHandle(account: cachedAccount.account, status: .expired(error))
        } else {
            accountCollection[address] =
                AccountHandle(localAccount: localAccount, status: .fault(error))
        }
    }
    
    private func blockProcessorWillFetchAssetDetails(
        for account: Account
    ) {
        let address = account.address
        
        if let cachedAccount = accountCollection[address],
           cachedAccount.canRefreshAssetDetails() {
            accountCollection[address] =
                AccountHandle(account: account, status: .refreshingAssetDetails)
        } else {
            accountCollection[address] =
                AccountHandle(account: account, status: .loadingAssetDetails)
        }
    }
    
    private func blockProcessorDidFetchAssetDetails(
        _ assetDetails: [AssetID: AssetInformation],
        for account: Account
    ) {
        accountCollection[account.address] = AccountHandle(account: account, status: .ready)
        
        assetDetails.forEach {
            assetDetailCollection[$0.key] = $0.value
        }
    }
    
    private func blockProcessorDidFailToFetchAssetDetails(
        _ error: HIPNetworkError<NoAPIModel>,
        for account: Account
    ) {
        let address = account.address
        
        if let cachedAccount = accountCollection[address],
           cachedAccount.status == .refreshingAssetDetails {
            accountCollection[address] =
                AccountHandle(account: account, status: .expiredAssetDetails(error))
        } else {
            accountCollection[address] =
                AccountHandle(account: account, status: .faultAssetDetails(error))
        }
    }
    
    private func blockProcessorDidFinish() {}
}
