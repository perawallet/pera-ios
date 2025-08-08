// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   SwapViewController.swift

import SwiftUI
import MacaroonUIKit

final class SwapViewController: BaseViewController {
    
    // MARK: - Properties
    
    var launchDraft: SwapAssetFlowDraft?
    
    private var selectedAccount: Account?
    private var selectedAssetIn: AssetItem?
    private var selectedAssetOut: AssetItem?
    private var payAmount: String?
    private var receiveAmount: String?
    
    private lazy var swapAssetFlowCoordinator = SwapAssetFlowCoordinator(
        draft: SwapAssetFlowDraft(),
        dataStore: SwapDataLocalStore(),
        configuration: configuration,
        presentingScreen: self
    )
    
    // MARK: - Initialisers
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarHidden = false
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if
            let launchDraft,
            let account = launchDraft.account
        {
            self.selectedAccount = account
            self.selectedAssetIn = assetItem(from: launchDraft.assetIn)
            self.selectedAssetOut = nil
            loadSwapView()
            self.launchDraft = nil
        } else {
            let defaultAccount = sharedDataController.accountCollection.map { $0.value }.filter { !$0.isWatchAccount }.first
            guard let defaultAccount else { return }
            
            self.selectedAccount = defaultAccount
            self.selectedAssetIn = nil
            self.selectedAssetOut = nil
            loadSwapView()
        }
    }
    
    private func loadSwapView() {
        let swapHostingController = UIHostingController(
            rootView: createSwapView()
        )

        if let existingController = children.first(where: { $0 is UIHostingController<SwapView> }) {
            existingController.willMove(toParent: nil)
            existingController.view.removeFromSuperview()
            existingController.removeFromParent()
        }

        addChild(swapHostingController)
        swapHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(swapHostingController.view)
        swapHostingController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        swapHostingController.didMove(toParent: self)
    }

    private func createSwapView() -> SwapView {
        guard let selectedAccount else {
            fatalError()
        }
        let defaultAsset = assetItem(from: selectedAccount[0])!
        
        var assetIn: AssetItem {
            guard let selectedAssetIn else {
                return defaultAsset
            }
            return selectedAssetIn
        }
        self.selectedAssetIn = assetIn
        
        var assetOut: AssetItem {
            guard let selectedAssetOut else {
                return defaultAsset
            }
            return selectedAssetOut
        }
        self.selectedAssetOut = assetOut
        
        let viewModel = SwapSharedViewModel(
            selectedAccount: selectedAccount,
            selectedAssetIn: assetIn,
            selectedAssetOut: assetOut
        )
        
        var rootView = SwapView(viewModel: viewModel)
        
        rootView.onTap = { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .showInfo:
                open(AlgorandWeb.tinymanSwap.link)
            case .selectAccount:
                swapAssetFlowCoordinator.onAccountSelected = { [weak self] selectedAccount in
                    guard let self = self else { return }
                    self.selectedAccount = selectedAccount
                    loadSwapView()
                }
                swapAssetFlowCoordinator.openSelectAccount()
            case .selectAssetIn(for: let account):
                print("payAssetSelection")
                swapAssetFlowCoordinator.onAssetInSelected = { [weak self] selectedAssetIn in
                    guard let self = self else { return }
                    self.selectedAssetIn = assetItem(from: selectedAssetIn)
                    loadSwapView()
                }
                swapAssetFlowCoordinator.openSelectAssetIn(account: account)
            case .selectAssetOut(for: let account):
                swapAssetFlowCoordinator.onAssetOutSelected = { [weak self] selectedAssetOut in
                    guard let self = self else { return }
                    self.selectedAssetOut = assetItem(from: selectedAssetOut)
                    loadSwapView()
                }
                swapAssetFlowCoordinator.openSelectAssetOut(account: account)
                
            case .switchAssets:
                let temp = selectedAssetIn
                selectedAssetIn = selectedAssetOut
                selectedAssetOut = temp
                loadSwapView()
            case .getQuote(for: let value):
                swapAssetFlowCoordinator.onQuoteLoaded = { [weak self] quote, error in
                    guard let self = self else { return }
                    if let error {
                        print(error)
                        return
                    }
                    receiveAmount = Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 4).string(for: quote?.amountOutUSDValue)
                    loadSwapView()
                }
                guard let assetIn = selectedAssetIn?.asset, let assetOut = selectedAssetOut?.asset else {
                    // error
                    return
                }
                payAmount = Formatter.decimalFormatter(minimumFractionDigits: 0, maximumFractionDigits: 4).string(for: value)
                swapAssetFlowCoordinator.getQoute(account: selectedAccount, assetIn: assetIn, assetOut: assetOut, amount: value)
                print("---quote for \(value)")
            }
        }
        
        return rootView
    }
    
    private func assetItem(from asset: Asset?) -> AssetItem? {
        guard let asset else { return nil }
        let assetItem = AssetItem(
            asset: asset,
            currency: sharedDataController.currency,
            currencyFormatter: .init(),
            isAmountHidden: false
        )
        return assetItem
    }
}
