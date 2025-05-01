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

//   SwapContainerVC.swift

final class SwapContainerVC: BaseViewController {
    override var prefersLargeTitle: Bool {
        return true
    }
    
    private lazy var swapAssetFlowCoordinator = SwapAssetFlowCoordinator(
        draft: SwapAssetFlowDraft(),
        dataStore: SwapDataLocalStore(),
        analytics: analytics,
        api: api!,
        sharedDataController: sharedDataController,
        loadingController: loadingController!,
        bannerController: bannerController!,
        presentingScreen: self
    )
    
    override init(configuration: ViewControllerConfiguration) {
        super.init(configuration: configuration)
    }
    
    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        swapAssetFlowCoordinator.resetDraft()
        swapAssetFlowCoordinator.launch()
    }
    
}
