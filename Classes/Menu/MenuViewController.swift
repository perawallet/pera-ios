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

//   MenuViewController.swift

final class MenuViewController: BaseViewController {
    
    override var prefersLargeTitle: Bool {
        return false
    }
    
    override init(configuration: ViewControllerConfiguration) {
        super.init(configuration: configuration)
        title = "Menu"
    }
    
    override func configureNavigationBarAppearance() {
        configureNotificationBarButton()
    }
    
    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }
    
}

extension MenuViewController {
    private func configureNotificationBarButton() {
        let notificationBarButtonItem = ALGBarButtonItem(kind: .settings) { [weak self] in
            guard let self = self else {
                return
            }

            self.open(
                .settings,
                by: .push
            )
        }

        rightBarButtonItems = [notificationBarButtonItem]
    }
}

extension MenuViewController {
    private func loadCollectibles() {
        let collectibleListQuery = CollectibleListQuery(
            filteringBy: .init(),
            sortingBy: configuration.sharedDataController.selectedCollectibleSortingAlgorithm
        )
        let collectibleListVC = CollectiblesViewController(
            query: collectibleListQuery,
            dataController: CollectibleListLocalDataController(
                galleryAccount: .all,
                sharedDataController: configuration.sharedDataController
            ),
            copyToClipboardController: ALGCopyToClipboardController(
                toastPresentationController: configuration.toastPresentationController!
            ),
            configuration: configuration
        )
    }
}
