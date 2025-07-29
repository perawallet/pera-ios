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

final class SwapViewController: UIHostingController<SwapView>, TabBarConfigurable {
    
    // MARK: - Properties
    var tabBarHidden: Bool
    var tabBarSnapshot: UIView?
    let configuration: ViewControllerConfiguration
    
    private lazy var swapAssetFlowCoordinator = SwapAssetFlowCoordinator(
        draft: SwapAssetFlowDraft(),
        dataStore: SwapDataLocalStore(),
        configuration: configuration,
        presentingScreen: self
    )
    
    // MARK: - Initialisers
    
    init(configuration: ViewControllerConfiguration) {
        self.configuration = configuration
        tabBarHidden = false
        super.init(rootView: SwapView())

        rootView.onTap = { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .info:
                open(AlgorandWeb.tinymanSwap.link)
            case .accountSelection:
                swapAssetFlowCoordinator.openSelectAccount()
            case .payAssetSelection:
                print("payAssetSelection")
            case .receiveAssetSelection:
                print("receiveAssetSelection")
            }
        }
    }
    
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}
