// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CollectibleListViewController.swift

import Foundation

final class CollectibleListViewController: BaseViewController {
    override var prefersLargeTitle: Bool {
        return true
    }
    
    override var name: AnalyticsScreenName? {
        return .collectibles
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
        bindNavigationItemTitle()
    }

    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }
}

extension CollectibleListViewController {
    private func addBarButtons() {
        let addBarButtonItem = ALGBarButtonItem(kind: .add) { [weak self] in
            guard let self = self else {
                return
            }

            fatalError("Not implemented yet.")
        }

        rightBarButtonItems = [addBarButtonItem]
    }

    private func bindNavigationItemTitle() {
        title = "title-collectibles".localized
    }
}
