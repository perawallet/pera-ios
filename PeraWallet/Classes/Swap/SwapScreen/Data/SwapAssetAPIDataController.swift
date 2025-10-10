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

//   SwapAssetAPIDataController.swift

import Foundation
import MacaroonUtils
import MagpieCore
import MagpieHipo
import pera_wallet_core

final class SwapAssetAPIDataController:
    SwapAssetDataController,
    SharedDataControllerObserver {
    typealias DataStore = SwapMutableAmountPercentageStore
    
    var eventHandler: EventHandler?
    
    var account: Account {
        get {
            swapController.account
        }
        set {
            swapController.account = newValue
        }
    }
    var userAsset: Asset {
        get {
            swapController.userAsset
        }
        set {
            swapController.userAsset = newValue
        }
    }
    var poolAsset: Asset? {
        get {
            swapController.poolAsset
        }
        
        set {
            swapController.poolAsset = newValue
        }
    }
    
    private var quote: SwapQuote? {
        swapController.quote
    }
    private var providers: [SwapProvider] {
        swapController.providers
    }
    private var providersV2: [SwapProviderV2] {
        swapController.providersV2
    }
    private var swapType: SwapType {
        swapController.swapType
    }
    
    private var currentQuoteEndpoint: EndpointOperatable?
    private lazy var quoteThrottler = Throttler(intervalInSeconds: 0.8)
    
    private var swapController: SwapController
    
    private let dataStore: DataStore
    private let api: ALGAPI
    private let sharedDataController: SharedDataController
    private let featureFlagService: FeatureFlagServicing
    
    init(
        dataStore: DataStore,
        swapController: SwapController,
        api: ALGAPI,
        sharedDataController: SharedDataController,
        featureFlagService: FeatureFlagServicing
    ) {
        self.dataStore = dataStore
        self.swapController = swapController
        self.api = api
        self.sharedDataController = sharedDataController
        self.featureFlagService = featureFlagService
        
        sharedDataController.add(self)
    }
    
    deinit {
        sharedDataController.remove(self)
    }
}

extension SwapAssetAPIDataController {
    func loadQuote(
        swapAmount: UInt64
    ) {
        guard let deviceID = api.session.authenticatedUser?.getDeviceId(on: api.network),
              let poolAssetID = poolAsset?.id else {
            return
        }
        
        let draft = SwapQuoteDraft(
            providers: featureFlagService.isEnabled(.swapV2Enabled) ? providersV2.map { $0.name } : providers.map { $0.rawValue },
            swapperAddress: account.address,
            type: swapType,
            deviceID: deviceID,
            assetInID: userAsset.id,
            assetOutID: poolAssetID,
            amount: swapAmount,
            slippage: swapController.slippage
        )
        
        eventHandler?(.willLoadQuote)
        
        if currentQuoteEndpoint != nil {
            cancelLoadingQuote()
        }
        
        quoteThrottler.performNext {
            [weak self] in
            guard let self = self else { return }
            
            if featureFlagService.isEnabled(.swapV2Enabled) {
                loadDataV2(draft)
            } else {
                loadData(draft)
            }
        }
    }
    
    private func loadData(
        _ draft: SwapQuoteDraft
    ) {
        currentQuoteEndpoint = api.getSwapQuote(draft) {
            [weak self] response in
            guard let self = self else { return }
            currentQuoteEndpoint = nil
            
            switch response {
            case .success(let quoteList):
                guard let quote = quoteList.results[safe: 0] else { return }
                swapController.quote = quote
                eventHandler?(.didLoadQuote(quote))
            case .failure(let apiError, let hipApiError):
                let error = HIPNetworkError(
                    apiError: apiError,
                    apiErrorDetail: hipApiError
                )
                eventHandler?(.didFailToLoadQuote(error))
            }
        }
    }
    
    private func loadDataV2(
        _ draft: SwapQuoteDraft
    ) {
        currentQuoteEndpoint = api.getSwapV2Quote(draft) {
            [weak self] response in
            guard let self = self else { return }
            currentQuoteEndpoint = nil
            
            switch response {
            case .success(let quoteList):
                guard let quote = quoteList.results[safe: 0] else { return }
                swapController.quote = quote
                eventHandler?(.didLoadQuoteV2(quoteList.results))
            case .failure(let apiError, let hipApiError):
                let error = HIPNetworkError(
                    apiError: apiError,
                    apiErrorDetail: hipApiError
                )
                eventHandler?(.didFailToLoadQuote(error))
            }
        }
    }
    
    func cancelLoadingQuote() {
        cancelOngoingRequest()
        quoteThrottler.cancelAll()
    }
    
    private func cancelOngoingRequest() {
        currentQuoteEndpoint?.cancel()
        currentQuoteEndpoint = nil
    }
}

extension SwapAssetAPIDataController {
    func saveAmountPercentage(_ percentage: SwapAmountPercentage?) {
        dataStore.amountPercentage = percentage
    }
}

extension SwapAssetAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            updateAccountIfNeeded()
        }
    }
    
    private func updateAccountIfNeeded() {
        guard let updatedAccount = sharedDataController.accountCollection[account.address] else {
            return
        }
        
        if !updatedAccount.isAvailable { return }
        
        self.account = updatedAccount.value
    }
}
