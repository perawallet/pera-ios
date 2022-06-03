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

//   ManagementOptionsViewController.swift

import Foundation
import MacaroonBottomSheet
import MacaroonUIKit
import SwiftUI

final class AssetManagementViewController:
    BaseScrollViewController,
    BottomSheetPresentable {
    private lazy var theme = Theme()
    private lazy var contextView = VStackView()
    
    override func configureAppearance() {
        title = "options-manage-assets".localized
    }
    
    override func configureNavigationBarAppearance() {
        addBarButtons()
    }
    
    private func addBarButtons() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) {
            [weak self] in
            self?.dismissScreen()
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }

    private func build() {
        addBackground()
        addContext()
        addActions()
    }
}

extension AssetManagementViewController {
    private func addBackground() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    
    private func addContext() {
        contentView.addSubview(contextView)

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
    }
    
    private func addActions() {
        addSortAction()
        addRemoveAction()
    }
    
    private func addSortAction() {
        addAction(
            SortListActionViewModel(),
            #selector(sort)
        )
    }
    
    private func addRemoveAction() {
        addAction(
            RemoveAssetsListActionViewModel(),
            #selector(removeAssets)
        )
    }
    
    private func addAction(
        _ viewModel: ListActionViewModel,
        _ selector: Selector
    ) {
        let actionView = ListActionView()
        
        actionView.customize(theme.listActionViewTheme)
        actionView.bindData(viewModel)
        
        contextView.addArrangedSubview(actionView)
        
        actionView.addTouch(
            target: self,
            action: selector
        )
    }
}

extension AssetManagementViewController {
    @objc
    private func sort() {}

    @objc
    private func removeAssets() {}
}
