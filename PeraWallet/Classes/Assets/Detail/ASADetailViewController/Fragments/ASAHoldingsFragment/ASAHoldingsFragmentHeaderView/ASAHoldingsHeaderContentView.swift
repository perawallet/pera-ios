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

//   ASAHoldingsHeaderContentView.swift

import UIKit
import Combine
import pera_wallet_core

final class ASAHoldingsHeaderContentView: UIView {

    private lazy var profileView = ASAProfileView()
    private lazy var quickActionsView = ASADetailQuickActionsView()

    private let theme = ASADetailViewControllerTheme()
    private var cancellables = Set<AnyCancellable>()

    private var account: Account?
    private var asset: Asset?
    private var chartData: ChartViewData?
    private var currency: CurrencyProvider?
    private var shouldDisplayQuickActions = false
    private var quickActionsViewModel: ASADetailQuickActionsViewModel?
    private var eventHandler: ASADetailViewController.EventHandler?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCallbacks()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(context: ASAHoldingsHeaderContext) {
        self.account = context.account
        self.asset = context.asset
        self.chartData = context.chartData
        self.currency = context.currency
        self.shouldDisplayQuickActions = context.shouldDisplayQuickActions
        self.quickActionsViewModel = context.quickActionsViewModel
        self.eventHandler = context.eventHandler

        setupLayout()
    }

    private func setupCallbacks() {
        ObservableUserDefaults.shared.$isPrivacyModeEnabled
            .sink { [weak self] in self?.bindProfileData(isAmountHidden: $0) }
            .store(in: &cancellables)
    }

    private func setupLayout() {
        removeAllSubviews()
        addProfile()
        
        if shouldDisplayQuickActions {
            addQuickActions()
        }
    }
    
    private func addProfile() {
        profileView.customize(theme.profile)
        profileView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(profileView)
        
        profileView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
        
        bindProfile()
    }

    private func bindProfile() {
        profileView.startObserving(event: .onAmountTap) {
            ObservableUserDefaults.shared.isPrivacyModeEnabled.toggle()
        }
        
        profileView.startObserving(event: .onFavoriteTap) { [weak self] in
            guard let self else { return }
            eventHandler?(.profileOnFavoriteTap)
        }
        
        profileView.startObserving(event: .onNotificationTap) { [weak self] in
            guard let self else { return }
            eventHandler?(.profileOnNotificationTap)
        }

        profileView.onPeriodChange = { [weak self] newPeriodSelected in
            guard let self, let account, let asset else { return }
            eventHandler?(.profileOnPeriodChange(account: account, asset: asset, newPeriodSelected: newPeriodSelected))
        }

        profileView.onPointSelected = { [weak self] pointSelected in
            guard let self else { return }

            guard
                let pointSelected,
                let date = pointSelected.timestamp.toDate(.fullNumericWithTimezone) ?? pointSelected.timestamp.toDate(.fullNumericWithTimezoneAndSeconds)
            else {
                bindProfileData(isAmountHidden: ObservableUserDefaults.shared.isPrivacyModeEnabled)
                return
            }

            let vm = ChartSelectedPointViewModel(
                algoValue: pointSelected.algoValue,
                fiatValue: pointSelected.fiatValue,
                usdValue: pointSelected.usdValue,
                dateValue: DateFormatter.chartDisplay.string(from: date)
            )
            bindProfileData(isAmountHidden: ObservableUserDefaults.shared.isPrivacyModeEnabled,
                            chartPointSelected: vm)
        }

        bindProfileData(isAmountHidden: ObservableUserDefaults.shared.isPrivacyModeEnabled)
        profileView.updateChart(with: chartData ?? ChartViewData(period: .oneWeek, chartValues: [], isLoading: false))
    }
    
    private func addQuickActions() {
        quickActionsView.customize(theme.quickActions)
        quickActionsView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(quickActionsView)
        
        quickActionsView.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(theme.quickActionsTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.equalToSuperview().inset(theme.quickActionsBottomPadding)
        }
        
        bindQuickActions()
    }

    private func bindQuickActions() {
        quickActionsView.startObserving(event: .buy) { [weak self] in
            guard let self else { return }
            eventHandler?(.quickActionsBuy)
        }

        quickActionsView.startObserving(event: .swap) { [weak self, weak quickActionsView] in
            guard let self, let quickActionsView else { return }

            if quickActionsViewModel?.isSwapBadgeVisible ?? false {
                quickActionsViewModel?.bindIsSwapBadgeVisible(isSwapBadgeVisible: false)
                quickActionsView.bindData(quickActionsViewModel)
            }

            eventHandler?(.quickActionsSwap)
        }

        quickActionsView.startObserving(event: .send) { [weak self] in
            guard let self else { return }
            eventHandler?(.quickActionsSend)
        }

        quickActionsView.startObserving(event: .receive) { [weak self] in
            guard let self else { return }
            eventHandler?(.quickActionsReceive)
        }

        quickActionsView.bindData(quickActionsViewModel)
    }

    private func bindProfileData(isAmountHidden: Bool, chartPointSelected: ChartSelectedPointViewModel? = nil) {
        guard let asset, let currency else { return }

        let viewModel = ASADetailProfileViewModel(
            asset: asset,
            currency: currency,
            currencyFormatter: CurrencyFormatter(),
            isAmountHidden: isAmountHidden,
            selectedPointVM: chartPointSelected
        )

        profileView.bindData(viewModel)
    }
}
