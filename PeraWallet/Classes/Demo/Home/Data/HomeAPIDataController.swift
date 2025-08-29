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

//
//   AccountsPortfolioAPIDataController.swift

import UIKit
import MacaroonUtils
import Combine
import pera_wallet_core

final class HomeAPIDataController:
    HomeDataController,
    SharedDataControllerObserver {
    var eventHandler: ((HomeDataControllerEvent) -> Void)?

    private let session: Session
    private let api: ALGAPI
    private let sharedDataController: SharedDataController
    private let announcementDataController: AnnouncementAPIDataController
    private let spotBannersDataController: SpotBannersAPIDataController
    private let chartsDataController: ChartAPIDataController
    private let incomingASAsAPIDataController: IncomingASAsAPIDataController
    private let featureFlagService: FeatureFlagServicing

    private var visibleAnnouncement: Announcement?
    private var spotBanners: [CarouselBannerItemModel]?
    private var chartViewData: ChartViewData?
    private var totalPortfolioItem: TotalPortfolioItem?
    private var chartSelectedPointViewModel: ChartSelectedPointViewModel?
    private var chartDataCache: [ChartDataPeriod: ChartViewData] = [:]
    private var incomingASAsRequestList: IncomingASAsRequestList?
    
    private var lastSnapshot: Snapshot?

    private let snapshotQueue = DispatchQueue(
        label: "pera.queue.home.updates",
        qos: .userInitiated
    )

    private var asasLoadRepeater: Repeater?
    private var cancellables = Set<AnyCancellable>()
    
    init(
        configuration: AppConfiguration,
        announcementDataController: AnnouncementAPIDataController,
        spotBannersDataController: SpotBannersAPIDataController,
        chartsDataController: ChartAPIDataController,
        incomingASAsAPIDataController: IncomingASAsAPIDataController
    ) {
        self.sharedDataController = configuration.sharedDataController
        self.session = configuration.session
        self.api = configuration.api
        self.announcementDataController = announcementDataController
        self.spotBannersDataController = spotBannersDataController
        self.chartsDataController = chartsDataController
        self.incomingASAsAPIDataController = incomingASAsAPIDataController
        self.featureFlagService = configuration.featureFlagService
        
        setupCallbacks()
    }
    
    deinit {
        sharedDataController.remove(self)
        stopASAsLoadTimer()
    }

    subscript (address: String?) -> AccountHandle? {
        return address.unwrap {
            sharedDataController.accountCollection[$0]
        }
    }
    
    private func setupCallbacks() {
        ObservableUserDefaults.shared.$isPrivacyModeEnabled
            .sink { [weak self] _ in self?.deliverContentUpdates() }
            .store(in: &cancellables)
    }
}

extension HomeAPIDataController {
    func load() {
        sharedDataController.add(self)
        announcementDataController.delegate = self
        incomingASAsAPIDataController.delegate = self
        setupSpotsBannersClosures()
        if featureFlagService.isEnabled(.portfolioChartsEnabled) {
            setupChartDataClosures()
        }
    }
    
    func reload() {
        deliverContentUpdates()
    }
    
    func fetchAnnouncements() {
        announcementDataController.loadData()
    }
    
    func fetchSpotBanners() {
        let accounts = self.sharedDataController.sortedAccounts()
        let shouldDisplayCriticalWarningForNotBackedUpAccounts = shouldDisplayCriticalWarningForNotBackedUpAccounts(accounts)
        spotBannersDataController.loadData(shouldAddBackupBanner: shouldDisplayCriticalWarningForNotBackedUpAccounts)
    }
    
    func updatePortfolio(with selectedPoint: ChartDataPoint?) {
        guard let point = selectedPoint else {
            chartSelectedPointViewModel = nil
            publish(.didSelectChartPoint(nil, totalPortfolioItem))
            return
        }

        guard let date = point.timestamp.toDate(.fullNumericWithTimezone) else {
            return
        }
        
        let dateValue = DateFormatter.chartDisplay.string(from: date)

        let viewModel = ChartSelectedPointViewModel(algoValue: point.algoValue, fiatValue: point.fiatValue, usdValue: point.usdValue, dateValue: dateValue)
        chartSelectedPointViewModel = viewModel
        publish(.didSelectChartPoint(chartSelectedPointViewModel, totalPortfolioItem))
    }
    
    func fetchInitialChartData(period: ChartDataPeriod) {
        chartDataCache.removeAll()
        chartsDataController.loadData(screen: .home, period: period)
    }
    
    func updateChartData(period: ChartDataPeriod) {
        guard let viewModel = chartDataCache[period] else {
            chartsDataController.loadData(screen: .home, period: period)
            return
        }
        chartViewData = viewModel
    }
    
    func updateClose(for banner: CarouselBannerItemModel) {
        spotBannersDataController.updateClose(for: banner)
    }

    func hideAnnouncement() {
        defer {
            self.visibleAnnouncement = nil
            reload()
        }

        guard let visibleAnnouncement = self.visibleAnnouncement else {
            return
        }

        announcementDataController.hideAnnouncement(visibleAnnouncement)
    }
    
    func fetchIncomingASAsRequests() {
        asasLoadRepeater = Repeater(intervalInSeconds: 6) {
            [weak self] in
            guard let self else { return }

            asyncMain { [weak self] in
                guard let self else { return }
                
                let filteredAccounts = sharedDataController.accountCollection.filter {
                    $0.value.isWatchAccount == false
                }
                let addresses = filteredAccounts.map({$0.value.address})
                guard addresses.isNonEmpty else { return }
                incomingASAsAPIDataController.fetchRequests(addresses: addresses)
            }
        }
        
        asasLoadRepeater?.resume(immediately: true)
    }
    
    private func stopASAsLoadTimer() {
        asasLoadRepeater?.invalidate()
        asasLoadRepeater = nil
    }
    
    private func setupSpotsBannersClosures() {
        spotBannersDataController.onFetch = { [weak self] error, banners in
            guard let self = self else { return }
            spotBanners = banners.sorted {
                if $0.isBackupBanner != $1.isBackupBanner {
                    return $0.isBackupBanner
                }
                return $0.id < $1.id
            }
            if let error {
                publish(.didUpdateSpotBanner(error))
            }
        }
        
        spotBannersDataController.onUpdateClose = { [weak self] error in
            guard let self = self else { return }
            publish(.didUpdateSpotBanner(error))
        }
    }
    
    private func setupChartDataClosures() {
        chartsDataController.onFetch = { [weak self] error, period, chartsData in
            guard let self else { return }
            guard error == nil else {
                chartViewData = ChartViewData(period: period, chartValues: [], isLoading: false)
                publish(.didFailWithError(error))
                return
            }
            let chartDataPoints: [ChartDataPoint] = chartsData.enumerated().compactMap { index, item -> ChartDataPoint? in
                guard
                    let algoValue = Double(item.algoValue),
                    let fiatValue = Double(item.valueInCurrency),
                    let usdValue = Double(item.usdValue)
                else { return nil }
                return ChartDataPoint(day: index, algoValue: algoValue, fiatValue: fiatValue, usdValue: usdValue, timestamp: item.datetime)
            }
            chartViewData = ChartViewData(period: period, chartValues: chartDataPoints, isLoading: false)
            chartDataCache[period] = chartViewData
        }
    }
    
    func fetchDefaultAssets() {
        let usdcAssetID = ALGAsset.usdcAssetID(api.network)
        guard
            sharedDataController.assetDetailCollection.isEmpty ||
            sharedDataController.assetDetailCollection.first(where: { $0.id == usdcAssetID }) == nil
        else {
            return
        }
        api.fetchAssetDetails(
            AssetFetchQuery(ids: [usdcAssetID]),
            queue: .main,
            ignoreResponseOnCancelled: false
        ) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let assetDetailResponse):
                assetDetailResponse.results.forEach { [weak self] in
                    guard let self else { return }
                    sharedDataController.assetDetailCollection[$0.id] = $0
                }
            case .failure:
                break
            }
        }
    }
}

extension HomeAPIDataController {
    func sharedDataController(
        _ sharedDataController: SharedDataController,
        didPublish event: SharedDataControllerEvent
    ) {
        switch event {
        case .didBecomeIdle:
            deliverInitialUpdates()
        case .didStartRunning(let isFirst):
            if isFirst || lastSnapshot == nil {
                deliverInitialUpdates()
            }
        case .didFinishRunning:
            deliverContentUpdates()
        }
    }
}

extension HomeAPIDataController {
    private func deliverInitialUpdates() {
        if sharedDataController.isPollingAvailable {
            deliverLoadingUpdates()
        } else {
            deliverNoContentUpdates()
        }
    }
    
    private func deliverLoadingUpdates() {
        deliverUpdates {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.empty(.loading)],
                toSection: .empty
            )
            return (nil as TotalPortfolioItem?, snapshot)
        }
    }
    
    private func deliverContentUpdates() {
        if sharedDataController.accountCollection.isEmpty {
            deliverNoContentUpdates()
            return
        }
        
        deliverUpdates { [weak self] in
            
            guard let self else { return nil }
            
            let accounts = self.sharedDataController.sortedAccounts()
            let currency = self.sharedDataController.currency
            let isAmountHidden = ObservableUserDefaults.shared.isPrivacyModeEnabled
            
            var accountItems = accounts
                .map { AccountPortfolioItem(accountValue: $0, currency: currency, currencyFormatter: CurrencyFormatter(), isAmountHidden: isAmountHidden) }
                .map { AccountListItemViewModel($0) }
                .map { HomeAccountItemIdentifier.cell($0) }
                .map { HomeItemIdentifier.account($0) }
            
            var snapshot = Snapshot()
            
            snapshot.appendSections([.portfolio])

            let nonWatchAccounts = accounts.filter { !$0.value.authorization.isWatch }
            let totalPortfolioItem = TotalPortfolioItem(
                accountValues: nonWatchAccounts,
                currency: currency,
                currencyFormatter: CurrencyFormatter(),
                isAmountHidden: isAmountHidden
            )
            self.totalPortfolioItem = totalPortfolioItem
            let totalPortfolioViewModel = HomePortfolioViewModel(totalPortfolioItem, selectedPoint: chartSelectedPointViewModel)

            snapshot.appendItems(
                [.portfolio(.portfolio(totalPortfolioViewModel))],
                toSection: .portfolio
            )
            
            if
                featureFlagService.isEnabled(.portfolioChartsEnabled),
                let chartViewData
            {
                snapshot.appendItems(
                    [.portfolio(.charts(chartViewData))],
                    toSection: .portfolio
                )
            }

            /// <note>
            /// If accounts empty which means there is no any authenticated account, quick actions will be hidden.
            if !accounts.isEmpty {
                snapshot.appendItems(
                    [.portfolio(.quickActions)],
                    toSection: .portfolio
                )
            }

            let shouldDisplayCriticalWarningForNotBackedUpAccounts = shouldDisplayCriticalWarningForNotBackedUpAccounts(accounts)

            /// <note>
            /// If there is a critical warning, announcements section should not be displayed.
            if !shouldDisplayCriticalWarningForNotBackedUpAccounts {
                appendAnnouncementItemsIfNeeded(into: &snapshot)
            }
            
            if let spotBanners, spotBanners.isNonEmpty {
                appendCarouselBannerItemsIfNeeded(into: &snapshot)
            }

            if !accounts.isEmpty {
                let headerItem: HomeAccountItemIdentifier =
                    .header(ManagementItemViewModel(.account))
                accountItems.insert(
                    .account(headerItem),
                    at: 0
                )
                
                snapshot.appendSections([.accounts])
                snapshot.appendItems(
                    accountItems,
                    toSection: .accounts
                )
            }

            return (totalPortfolioItem, snapshot)
        }
    }
    
    private func deliverNoContentUpdates() {
        deliverUpdates {
            var snapshot = Snapshot()
            snapshot.appendSections([.empty])
            snapshot.appendItems(
                [.empty(.noContent)],
                toSection: .empty
            )
            return (nil as TotalPortfolioItem?, snapshot)
        }
    }
    
    private func deliverUpdates(
        _ updates: @escaping () -> Updates?
    ) {
        snapshotQueue.async {
            [weak self] in
            guard let self = self else { return }

            guard let updates = updates() else {
                return
            }

            self.publish(.didUpdate(updates))
        }
    }
}

extension HomeAPIDataController {
    private func publish(
        _ event: HomeDataControllerEvent
    ) {
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }
            
            self.lastSnapshot = event.snapshot
            self.eventHandler?(event)
        }
    }
}

extension HomeAPIDataController: AnnouncementAPIDataControllerDelegate {
    func announcementAPIDataController(
        _ dataController: AnnouncementAPIDataController,
        didFetch announcements: [Announcement]
    ) {
        self.visibleAnnouncement = announcements.first
    }
}

extension HomeAPIDataController: IncomingASAsAPIDataControllerDelegate {
    func incomingASAsAPIDataController(
        _ dataController: IncomingASAsAPIDataController,
        didFetch incomingASAsRequestList: IncomingASAsRequestList
    ) {
        self.incomingASAsRequestList = incomingASAsRequestList
        self.publish(.deliverASARequestsContentUpdate(incomingASAsRequestList))
    }
}

extension HomeAPIDataController {
    private func appendAnnouncementItemsIfNeeded(
        into snapshot: inout Snapshot
    ) {
        guard let visibleAnnouncement else { return  }

        snapshot.appendSections([ .announcement ])

        let viewModel = AnnouncementViewModel(visibleAnnouncement)
        let items = [ HomeItemIdentifier.announcement(viewModel) ]
        snapshot.appendItems(
            items,
            toSection: .announcement
        )
    }
    
    private func appendCarouselBannerItemsIfNeeded(
        into snapshot: inout Snapshot
    ) {
        guard let spotBanners else { return  }

        snapshot.appendSections([ .carouselBanner ])

        let items = [ HomeItemIdentifier.carouselBanner(spotBanners) ]
        snapshot.appendItems(
            items,
            toSection: .carouselBanner
        )
    }

    private func shouldDisplayCriticalWarningForNotBackedUpAccounts(_ accounts: [AccountHandle]) -> Bool {
        let shouldDisplay = accounts.contains {
            let account = $0.value
            if account.isBackedUp {
                return false
            }

            let rekeyedAccounts = getRekeyedAccounts(of: account)
            let hasAnyRekeyedAccounts = rekeyedAccounts.isNonEmpty
            if hasAnyRekeyedAccounts {
                return true
            }

            if account.algo.amount > 0 {
                return true
            }

            return false
        }
        return shouldDisplay
    }

    private func getRekeyedAccounts(of account: Account) -> [AccountHandle] {
        return sharedDataController.rekeyedAccounts(of: account)
    }
}
