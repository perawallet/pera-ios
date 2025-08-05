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
    
    private lazy var swapAssetFlowCoordinator = SwapAssetFlowCoordinator(
        draft: SwapAssetFlowDraft(),
        dataStore: SwapDataLocalStore(),
        configuration: configuration,
        presentingScreen: self
    )
    
    private lazy var swapHostingController = UIHostingController(rootView: makeSwapView(with: nil))
    
    // MARK: - Initialisers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSwapView()
    }
    
    private func addSwapView(with selectedAccount: AccountInformation? = nil) {
        if swapHostingController.parent != nil {
            swapHostingController.willMove(toParent: nil)
            swapHostingController.view.removeFromSuperview()
            swapHostingController.removeFromParent()
        }
        
        swapHostingController = UIHostingController(rootView: makeSwapView(with: selectedAccount))
        addChild(swapHostingController)
        swapHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(swapHostingController.view)
        swapHostingController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        swapHostingController.didMove(toParent: self)
    }
    
    private func makeSwapView(with selectedAccount: AccountInformation?) -> SwapView {
        var rootView = SwapView(selectedAccount: .constant(selectedAccount))
        
        rootView.onTap = { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .info:
                open(AlgorandWeb.tinymanSwap.link)
            case .accountSelection:
                swapAssetFlowCoordinator.onAccountSelected = { [weak self] selectedAccount in
                    guard let self = self else { return }
                    guard let account = configuration.session?.authenticatedUser?.account(address: selectedAccount.address) else {
                        return
                    }
                    addSwapView(with: account)
                }
                swapAssetFlowCoordinator.openSelectAccount()
            case .payAssetSelection:
                print("payAssetSelection")
            case .receiveAssetSelection:
                print("receiveAssetSelection")
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
        
        guard
            let launchDraft,
            let launchDraftAccountAddress = launchDraft.account?.address,
            let launchDraftAccount = configuration.session?.authenticatedUser?.account(address: launchDraftAccountAddress)
        else {
            let account = configuration.session?.authenticatedUser?.accounts
                .filter { !$0.isWatchAccount }
                .first
            addSwapView(with: account)
            return
        }
        addSwapView(with: launchDraftAccount)
        self.launchDraft = nil
    }
}
