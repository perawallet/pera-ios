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

//   ASAHoldingsFragment.swift

import UIKit
import pera_wallet_core

final class ASAHoldingsFragment: TransactionsViewController {
    
    init(
        account: Account,
        asset: Asset,
        dataController: ASADetailScreenDataController,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration,
        eventHandler: @escaping ASADetailViewController.EventHandler
    ) {
        let accountHandle = AccountHandle(account: account, status: .ready)

        let draft: TransactionListing
        if asset.isAlgo {
            /// <todo>
            /// We should have a standardized way of using `Account` or `AccountHandle`, and manage
            /// all related cases(success/failure) properly.
            draft = AlgoTransactionListing(accountHandle: accountHandle)
        } else {
            draft = AssetTransactionListing(
                accountHandle: accountHandle,
                asset: asset
            )
        }

        super.init(
            draft: draft,
            copyToClipboardController: copyToClipboardController,
            configuration: configuration
        )
        
        let viewModel = makeViewModel(for: asset)
        
        let context = makeContext(
            account: account,
            asset: asset,
            viewModel: viewModel,
            chartData: ChartViewData(period: .oneWeek, chartValues: [], isLoading: false),
            shouldDisplayQuickActions: dataController.configuration.shouldDisplayQuickActions,
            eventHandler: eventHandler
        )
        
        transactionsDataSource = TransactionsDataSource(listView, noContentType: .topAligned, headerContext: context)
    }
    
    private func makeViewModel(for asset: Asset) -> ASADetailQuickActionsViewModel {
        let swapDisplayStore = SwapDisplayStore()
        let isOnboardedToSwap = swapDisplayStore.isOnboardedToSwap
        return ASADetailQuickActionsViewModel(
            asset: asset,
            isSwapBadgeVisible: !isOnboardedToSwap
        )
    }
    
    private func makeContext(
        account: Account,
        asset: Asset,
        viewModel: ASADetailQuickActionsViewModel,
        chartData: ChartViewData,
        shouldDisplayQuickActions: Bool,
        eventHandler: @escaping ASADetailViewController.EventHandler
    ) -> ASAHoldingsHeaderContext {
        ASAHoldingsHeaderContext(
            account: account,
            asset: asset,
            currency: configuration.sharedDataController.currency,
            shouldDisplayQuickActions: shouldDisplayQuickActions,
            quickActionsViewModel: viewModel,
            chartData: chartData,
            eventHandler: eventHandler
        )
    }
    
    func updateHeader(with chartData: ChartViewData, shouldDisplayQuickActions: Bool, eventHandler: @escaping ASADetailViewController.EventHandler) {
        guard let asset else { return }
        let viewModel = makeViewModel(for: asset)
        let context = makeContext(
            account: draft.accountHandle.value,
            asset: asset,
            viewModel: viewModel,
            chartData: chartData,
            shouldDisplayQuickActions: shouldDisplayQuickActions,
            eventHandler: eventHandler
        )
        
        transactionsDataSource.updateHeader(with: context)
    }
}

struct ASAHoldingsHeaderContext {
    let account: Account
    let asset: Asset
    let currency: CurrencyProvider
    let shouldDisplayQuickActions: Bool
    let quickActionsViewModel: ASADetailQuickActionsViewModel
    let chartData: ChartViewData
    let eventHandler: ASADetailViewController.EventHandler
}
