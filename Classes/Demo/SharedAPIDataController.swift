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

final class SharedAPIDataController:
    SharedDataController,
    WeakPublisher {
    var observations: [ObjectIdentifier: WeakObservation] = [:]

    var assetDetailCollection: AssetDetailCollection = []

    private(set) var accountCollection: AccountCollection = []
    private(set) var currency: CurrencyHandle = .idle
    
    private lazy var blockProcessor = createBlockProcessor()
    private lazy var blockProcessorEventQueue =
        DispatchQueue(label: "com.algorand.queue.blockProcessor.events")
    
    @Atomic(identifier: "sharedAPIDataController.status")
    private var status: Status = .idle
    private var isFirstPollingRoundCompleted = false
    
    private let session: Session
    private let api: ALGAPI
    
    init(
        session: Session,
        api: ALGAPI
    ) {
        self.session = session
        self.api = api
    }
}

extension SharedAPIDataController {
    func startPolling() {
        if status.isActive {
            return
        }
        
        $status.modify { $0 = .running }

        blockProcessor.start()
    }
    
    func stopPolling() {
        if !status.isActive {
            return
        }
        
        blockProcessor.stop()

        $status.modify { $0 = .suspended }
        
        publishEventForCurrentStatus()
    }
    
    func reset() {
        stopPolling()
        deleteData()
        
        $status.modify { $0 = .completed }
        
        publishEventForCurrentStatus()
        
        $status.modify { $0 = .idle }
        
        startPolling()
    }
    
    func cancel() {
        blockProcessor.cancel()
        deleteData()
        
        $status.modify { $0 = .idle }
        
        publishEventForCurrentStatus()
    }
}

extension SharedAPIDataController {
    func add(
        _ observer: SharedDataControllerObserver
    ) {
        publishEventForCurrentStatus()
        
        let id = ObjectIdentifier(observer as AnyObject)
        observations[id] = WeakObservation(observer)
    }
}

extension SharedAPIDataController {
    private func deleteData() {
        currency = .idle
        accountCollection = []
        assetDetailCollection = []
    }
}

extension SharedAPIDataController {
    private func createBlockProcessor() -> BlockProcessor {
        let request: ALGBlockProcessor.BlockRequest = { [unowned self] in
            var request = ALGBlockRequest()
            request.localAccounts = self.session.authenticatedUser?.accounts ?? []
            /// <warning>
            request.cachedAccounts = AccountCollection(self.accountCollection)
            request.cachedAssetDetails = AssetDetailCollection(self.assetDetailCollection)
            request.localCurrencyId = self.session.preferredCurrency
            request.cachedCurrency = self.currency
            return request
        }
        let cycle = ALGBlockCycle(api: api)
        let processor = ALGBlockProcessor(blockRequest: request, blockCycle: cycle, api: api)
        
        processor.notify(queue: blockProcessorEventQueue) {
            [weak self] event in
            guard let self = self else { return }
            
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
    
    private func blockProcessorWillStart() {
        $status.modify { $0 = .running }
        publishEventForCurrentStatus()
    }
    
    private func blockProcessorWillFetchCurrency() {
        if let currencyValue = currency.value {
            currency = .refreshing(currencyValue)
        } else {
            currency = .loading
        }
        
        publish(.didUpdateCurrency)
    }
    
    private func blockProcessorDidFetchCurrency(
        _ currencyValue: Currency
    ) {
        currency = .ready(currency: currencyValue, lastUpdateDate: Date())
        publish(.didUpdateCurrency)
    }
    
    private func blockProcessorDidFailToFetchCurrency(
        _ error: HIPNetworkError<NoAPIModel>
    ) {
        if !currency.isAvailable {
            currency = .failed(error)
        }
        
        publish(.didUpdateCurrency)
    }
    
    private func blockProcessorWillFetchAccount(
        _ localAccount: AccountInformation
    ) {
        let address = localAccount.address
        let updatedAccount: AccountHandle

        if let cachedAccount = accountCollection[address],
           cachedAccount.canRefresh() {
            updatedAccount = AccountHandle(account: cachedAccount.value, status: .refreshing)
        } else {
            updatedAccount = AccountHandle(localAccount: localAccount, status: .loading)
        }
        
        accountCollection[address] = updatedAccount

        publish(.didUpdateAccountCollection(updatedAccount))
    }
    
    private func blockProcessorDidFetchAccount(
        _ account: Account
    ) {
        let updatedAccount = AccountHandle(account: account, status: .upToDate)
        accountCollection[account.address] = updatedAccount

        publish(.didUpdateAccountCollection(updatedAccount))
    }
    
    private func blockProcessorDidFailToFetchAccount(
        _ localAccount: AccountInformation,
        _ error: HIPNetworkError<NoAPIModel>
    ) {
        let address = localAccount.address
        let updatedAccount: AccountHandle
        
        if let cachedAccount = accountCollection[address],
           cachedAccount.status == .refreshing {
            updatedAccount = AccountHandle(account: cachedAccount.value, status: .expired(error))
        } else {
            updatedAccount = AccountHandle(localAccount: localAccount, status: .failed(error))
        }
        
        accountCollection[address] = updatedAccount
        
        publish(.didUpdateAccountCollection(updatedAccount))
    }
    
    private func blockProcessorWillFetchAssetDetails(
        for account: Account
    ) {
        let address = account.address
        let updatedAccount: AccountHandle
        
        if let cachedAccount = accountCollection[address],
           cachedAccount.canRefreshAssetDetails() {
            updatedAccount = AccountHandle(account: account, status: .refreshingAssetDetails)
        } else {
            updatedAccount = AccountHandle(account: account, status: .loadingAssetDetails)
        }
        
        accountCollection[address] = updatedAccount
        
        publish(.didUpdateAccountCollection(updatedAccount))
    }
    
    private func blockProcessorDidFetchAssetDetails(
        _ assetDetails: [AssetID: AssetInformation],
        for account: Account
    ) {
        let updatedAccount = AccountHandle(account: account, status: .ready)
        accountCollection[account.address] = updatedAccount
        
        publish(.didUpdateAccountCollection(updatedAccount))
        
        if assetDetails.isEmpty {
            return
        }
        
        assetDetails.forEach {
            assetDetailCollection[$0.key] = $0.value
        }
        
        publish(.didUpdateAssetDetailCollection)
    }
    
    private func blockProcessorDidFailToFetchAssetDetails(
        _ error: HIPNetworkError<NoAPIModel>,
        for account: Account
    ) {
        let address = account.address
        let updatedAccount: AccountHandle
        
        if let cachedAccount = accountCollection[address],
           cachedAccount.status == .refreshingAssetDetails {
            updatedAccount = AccountHandle(account: account, status: .expiredAssetDetails(error))
        } else {
            updatedAccount = AccountHandle(account: account, status: .failedAssetDetails(error))
        }
        
        accountCollection[address] = updatedAccount
        
        publish(.didUpdateAccountCollection(updatedAccount))
    }
    
    private func blockProcessorDidFinish() {
        isFirstPollingRoundCompleted = true
        $status.modify { $0 = .completed }
        
        publishEventForCurrentStatus()
    }
}

extension SharedAPIDataController {
    private func publishEventForCurrentStatus() {
        switch status {
        case .idle: publish(.didBecomeIdle)
        case .running: publish(.didStartRunning(first: !isFirstPollingRoundCompleted))
        case .suspended: publish(isFirstPollingRoundCompleted ? .didFinishRunning : .didBecomeIdle)
        case .completed: publish(.didFinishRunning)
        }
    }
    
    private func publish(
        _ event: SharedDataControllerEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }
            
            self.notifyObservers {
                $0.sharedDataController(
                    self,
                    didPublish: event
                )
            }
        }
    }
}

extension SharedAPIDataController {
    final class WeakObservation: WeakObservable {
        weak var observer: SharedDataControllerObserver?

        init(
            _ observer: SharedDataControllerObserver
        ) {
            self.observer = observer
        }
    }
}

extension SharedAPIDataController {
    private enum Status: Equatable {
        case idle
        case running
        case suspended
        case completed /// Waiting for the next polling cycle to be running
        
        var isActive: Bool {
            switch self {
            case .idle: return false
            case .running: return true
            case .suspended: return false
            case .completed: return true
            }
        }
    }
}
