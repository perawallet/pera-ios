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

//   AccountCollectibleListFilterSelectionViewController.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AccountCollectibleListFilterSelectionViewController: ScrollScreen {
    lazy var uiInteractions = UIInteractions()

    private lazy var contextView = VStackView()
    private lazy var displayOptedInCollectibleAssetsFilterItemView = AssetFilterItemView()

    private lazy var store = CollectibleFilterStore()

    private let theme: AccountCollectibleListFilterSelectionViewControllerTheme

    init(theme: AccountCollectibleListFilterSelectionViewControllerTheme = .init()) {
        self.theme = theme
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        addBarButtons()
        bindNavigationItemTitle()

        navigationItem.largeTitleDisplayMode =  .never
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
    }
}

extension AccountCollectibleListFilterSelectionViewController {
    private func addBarButtons() {
        let doneBarButtonItem = ALGBarButtonItem(kind: .done(Colors.Link.primary.uiColor)) {
            [unowned self] in
            performChanges()
        }

        rightBarButtonItems = [doneBarButtonItem]
    }

    private func bindNavigationItemTitle() {
        title = "collectible-filter-selection-title".localized
    }
}

extension AccountCollectibleListFilterSelectionViewController {
    private func addUI() {
        addBackground()
        addContext()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addContext() {
        contentView.addSubview(contextView)
        contextView.spacing = theme.spacingBetweenFilterItems
        contextView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: theme.contentPaddings.top,
            leading: theme.contentPaddings.leading,
            bottom: theme.contentPaddings.bottom,
            trailing: theme.contentPaddings.trailing
        )
        contextView.isLayoutMarginsRelativeArrangement = true
        contextView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        addFilterItems()
    }

    private func addFilterItems() {
        addDisplayOptedInCollectibleAssetsFilterItem()
    }

    private func addDisplayOptedInCollectibleAssetsFilterItem() {
        displayOptedInCollectibleAssetsFilterItemView.customize(theme.filterItem)
        displayOptedInCollectibleAssetsFilterItemView.bindData(DisplayOptedInCollectibleAssetsFilterItemViewModel())

        displayOptedInCollectibleAssetsFilterItemView.isOn = store.displayOptedInCollectibleAssets

        contextView.addArrangedSubview(displayOptedInCollectibleAssetsFilterItemView)
    }
}

extension AccountCollectibleListFilterSelectionViewController {
    private func performChanges() {
        let hasChanges = hasChanges()

        if hasChanges {
            saveFilters()
        }

        uiInteractions.didComplete?(hasChanges)
    }

    private func saveFilters() {
        var store = CollectibleFilterStore()
        store.displayOptedInCollectibleAssets = displayOptedInCollectibleAssetsFilterItemView.isOn
    }

    private func hasChanges() -> Bool {
        let store = CollectibleFilterStore()

        let hasChanges = store.displayOptedInCollectibleAssets != displayOptedInCollectibleAssetsFilterItemView.isOn
        return hasChanges
    }
}

extension AccountCollectibleListFilterSelectionViewController {
    struct UIInteractions {
        typealias HasChanges = Bool
        var didComplete: ((HasChanges) -> Void)?
    }
}
