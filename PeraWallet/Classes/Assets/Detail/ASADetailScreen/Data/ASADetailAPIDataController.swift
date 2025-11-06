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

//   ASADetailAPIDataController.swift

import Foundation
import MagpieHipo
import pera_wallet_core

final class ASADetailScreenAPIDataController:
    ASADetailScreenDataController,
    SharedDataControllerObserver {
    var eventHandler: EventHandler?

    private(set) var configuration: ASADetailScreenConfiguration

    private(set) var account: Account {
        didSet { publishEventWhenAccountDidUpdate(oldAccount: oldValue) }
    }

    private(set) var asset: Asset
    private(set) var chartViewData: ChartViewData?

    private var assetDetail: AssetDecoration?

    private let api: ALGAPI
    private let sharedDataController: SharedDataController
    private let chartsDataController: ChartAPIDataController
    private let featureFlagService: FeatureFlagServicing
    
    private var chartDataCache: [ChartDataPeriod: ChartViewData] = [:]
    private var priceChartDataCache: [ChartDataPeriod: ChartViewData] = [:]

    init(
        account: Account,
        asset: Asset,
        appConfiguration: AppConfiguration,
        chartsDataController: ChartAPIDataController,
        configuration: ASADetailScreenConfiguration?
    ) {
        self.account = account
        self.asset = asset
        self.api = appConfiguration.api
        self.sharedDataController = appConfiguration.sharedDataController
        self.chartsDataController = chartsDataController
        self.featureFlagService = appConfiguration.featureFlagService

        lazy var defaultConfiguration = ASADetailScreenConfiguration(
            shouldDisplayAccountActionsBarButtonItem: true,
            shouldDisplayQuickActions: !account.authorization.isWatch
        )
        self.configuration = configuration ?? defaultConfiguration
    }

    deinit {
        sharedDataController.remove(self)
    }
}

extension ASADetailScreenAPIDataController {
    func loadData() {
        setupChartDataClosures()

        eventHandler?(.willLoadData)

        let draft = AssetDetailFetchDraft(id: asset.id, deviceId: api.deviceId)
        api.fetchAssetDetail(draft) {
            [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let newAssetDetail):
                let algAsset = ALGAsset(asset: self.asset)
                self.asset = StandardAsset(asset: algAsset, decoration: newAssetDetail)
                self.assetDetail = newAssetDetail

                self.didLoadData()
            case .failure(let apiError, let apiErrorDetail):
                self.assetDetail = nil
                self.sharedDataController.remove(self)

                let error = HIPNetworkError(apiError: apiError, apiErrorDetail: apiErrorDetail)
                self.eventHandler?(.didFailToLoadData(error))
            }
        }
    }

    private func didLoadData() {
        self.eventHandler?(.didLoadData)
        self.sharedDataController.add(self)
    }
    
    func fetchInitialChartData(address: String, assetId: String, period: ChartDataPeriod) {
        chartDataCache.removeAll()
        chartsDataController.loadData(screen: .asset(address: address, assetId: assetId), period: period)
    }
    
    func fetchInitialAssetPriceChartData(assetId: AssetID, period: ChartDataPeriod) {
        priceChartDataCache.removeAll()
        chartsDataController.loadData(screen: .assetPrice(assetId: assetId), period: period)
    }
    
    func updateChartData(address: String, assetId: String, period: ChartDataPeriod) {
        guard let viewModel = chartDataCache[period] else {
            chartsDataController.loadData(screen: .asset(address: address, assetId: assetId), period: period)
            return
        }
        chartViewData = viewModel
        eventHandler?(.didFetchChartData(data: chartViewData, error: nil, period: period))
    }
    
    func updateAssetPriceChartData(assetId: AssetID, period: ChartDataPeriod) {
        guard let viewModel = priceChartDataCache[period] else {
            chartsDataController.loadData(screen: .assetPrice(assetId: assetId), period: period)
            return
        }
        chartViewData = viewModel
        eventHandler?(.didFetchPriceChartData(data: chartViewData, error: nil, period: period))
    }
    
    private func setupChartDataClosures() {
        chartsDataController.onAssetFetch = { [weak self] error, period, chartsData in
            guard let self else { return }
            guard error == nil else {
                chartViewData = ChartViewData(period: period, chartValues: [], isLoading: false)
                eventHandler?(.didFetchChartData(data: nil, error: error, period: period))
                return
            }
            let chartDataPoints: [ChartDataPoint] = chartsData.enumerated().compactMap { index, item -> ChartDataPoint? in
                guard
                    let algoValue = Double(item.amount),
                    let fiatValue = Double(item.valueInCurrency),
                    let usdValue = Double(item.usdValue)
                else { return nil }
                return ChartDataPoint(day: index, algoValue: algoValue, fiatValue: fiatValue, usdValue: usdValue, timestamp: item.datetime)
            }
            chartViewData = ChartViewData(period: period, chartValues: chartDataPoints, isLoading: false)
            chartDataCache[period] = chartViewData
            eventHandler?(.didFetchChartData(data: chartViewData, error: nil, period: period))
        }
        
        chartsDataController.onAssetPriceFetch = { [weak self] error, period, chartsData in
            guard let self else { return }
            guard error == nil else {
                chartViewData = ChartViewData(period: period, chartValues: [], isLoading: false)
                eventHandler?(.didFetchPriceChartData(data: nil, error: error, period: period))
                return
            }
            let chartDataPoints: [ChartDataPoint] = chartsData.enumerated().compactMap { index, item -> ChartDataPoint? in
                return ChartDataPoint(day: index, algoValue: 0.0, fiatValue: item.price, usdValue: 0.0, timestamp: item.datetime)
            }
            chartViewData = ChartViewData(period: period, chartValues: chartDataPoints, isLoading: false)
            priceChartDataCache[period] = chartViewData
            eventHandler?(.didFetchPriceChartData(data: chartViewData, error: nil, period: period))
        }
        
        chartsDataController.onAssetPriceFetch = { [weak self] error, period, chartsData in
            guard let self else { return }
            guard error == nil else {
                chartViewData = ChartViewData(period: period, chartValues: [], isLoading: false)
                eventHandler?(.didFetchPriceChartData(data: nil, error: error, period: period))
                return
            }
            let chartDataPoints: [ChartDataPoint] = chartsData.enumerated().compactMap { index, item -> ChartDataPoint? in
                return ChartDataPoint(day: index, algoValue: 0.0, fiatValue: item.price, usdValue: 0.0, timestamp: item.datetime)
            }
            chartViewData = ChartViewData(period: period, chartValues: chartDataPoints, isLoading: false)
            priceChartDataCache[period] = chartViewData
            eventHandler?(.didFetchPriceChartData(data: chartViewData, error: nil, period: period))
        }
    }
    
    func toogleFavoriteStatus() {
        guard let deviceIdString = api.deviceId, let deviceId = Int64(deviceIdString) else { return }
        
        api.tooggleFavoriteStatus(AssetToogleStatusDraft(deviceId: deviceId, enabled: !(asset.isFavorited ?? false)), and: String(asset.id)) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success:
                loadData()
            case .failure:
                eventHandler?(.didFailToToogleStatus(String(localized: "toggle-favorites-error-message")))
            }
        }
    }
    
    func tooglePriceAlertStatus() {
        guard let deviceIdString = api.deviceId, let deviceId = Int64(deviceIdString) else { return }
        
        api.toogglePriceAlertStatus(AssetToogleStatusDraft(deviceId: deviceId, enabled: !(asset.isPriceAlertEnabled ?? false)), and: String(asset.id)) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success:
                loadData()
            case .failure:
                eventHandler?(.didFailToToogleStatus(String(localized: "toggle-price-alert-error-message")))
            }
        }
    }
}

/// <mark>
/// SharedDataControllerObserver
extension ASADetailScreenAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        if case .didFinishRunning = event {
            publishEventIfAssetDidUpdate()
        }
    }

    private func publishEventIfAssetDidUpdate() {
        let address = account.address

        guard let newAccount = sharedDataController.accountCollection[address] else { return }

        if !newAccount.isAvailable { return }
        publishEventIfStandardAssetDidUpdate(newAccount.value)
        account = newAccount.value
    }

    private func publishEventIfStandardAssetDidUpdate(_ newAccount: Account) {
        guard let newAsset = newAccount[asset.id] else { return }

        guard let assetDetail = assetDetail else { return }

        if !isAssetUpdated(newAsset) { return }

        let algAsset = ALGAsset(asset: newAsset)
        asset = StandardAsset(asset: algAsset, decoration: assetDetail)
        eventHandler?(.didLoadData)
    }

    private func isAssetUpdated(_ newAsset: Asset) -> Bool {
        return
            newAsset.decimalAmount != asset.decimalAmount ||
            newAsset.usdValue != asset.usdValue
    }
}

extension ASADetailScreenAPIDataController {
    private func publishEventWhenAccountDidUpdate(oldAccount: Account) {
        eventHandler?(.didUpdateAccount(old: oldAccount))
    }
}
