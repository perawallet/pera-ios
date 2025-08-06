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
    
    private func addSwapView(with selectedAccount: Account, assetIn: Asset? = nil, assetOut: Asset? = nil) {
        let swapHostingController = UIHostingController(
            rootView: makeSwapView(with: selectedAccount, selectedAssetIn: assetIn, selectedAssetOut: assetOut)
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

    
    private func makeSwapView(with selectedAccount: Account, selectedAssetIn: Asset? = nil, selectedAssetOut: Asset? = nil) -> SwapView {
        let defaultAsset = selectedAccount[0]!
        
        var assetIn: Asset {
            guard let selectedAssetIn else {
                return defaultAsset
            }
            return selectedAssetIn
        }
        
        var assetOut: Asset {
            guard let selectedAssetOut else {
                return defaultAsset
            }
            return selectedAssetOut
        }
        
        var rootView = SwapView(selectedAccount: .constant(selectedAccount), selectedAssetIn: .constant(assetIn), selectedAssetOut: .constant(assetOut))
        
        rootView.onTap = { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .showInfo:
                open(AlgorandWeb.tinymanSwap.link)
            case .selectAccount:
                swapAssetFlowCoordinator.onAccountSelected = { [weak self] selectedAccount in
                    guard let self = self else { return }
                    addSwapView(with: selectedAccount)
                    self.selectedAccount = selectedAccount
                }
                swapAssetFlowCoordinator.openSelectAccount()
            case .selectAssetIn(for: let account):
                print("payAssetSelection")
                swapAssetFlowCoordinator.onAssetInSelected = { [weak self] selectedAssetIn in
                    guard let self = self else { return }
                    addSwapView(with: selectedAccount, assetIn: selectedAssetIn)
                }
                swapAssetFlowCoordinator.openSelectAssetIn(account: account)
            case .selectAssetOut(for: let account):
                swapAssetFlowCoordinator.onAssetOutSelected = { [weak self] selectedAssetOut in
                    guard let self = self else { return }
                    addSwapView(with: selectedAccount, assetOut: selectedAssetOut)
                }
                swapAssetFlowCoordinator.openSelectAssetOut(account: account)
            }
        }
        
        return rootView
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
            addSwapView(with: account, assetIn: launchDraft.assetIn)
            self.launchDraft = nil
            self.selectedAccount = account
        } else {
            let localAccount = configuration.session?.authenticatedUser?.accounts
                .filter { !$0.isWatchAccount }
                .first
            guard let localAccount else {
                // TODO: show no account warning and a button to create it
                return
            }
            let account = Account(localAccount: localAccount)
            addSwapView(with: account)
            self.selectedAccount = account
        }
    }
}
