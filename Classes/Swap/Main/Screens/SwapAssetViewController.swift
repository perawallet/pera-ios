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

//   SwapAssetViewController.swift

import MacaroonForm
import MacaroonUIKit
import UIKit

final class SwapAssetViewController: BaseScrollViewController {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private let draft: SwapScreenDraft
    private let theme: SwapAssetViewControllerTheme

    private lazy var swapActionView = MacaroonUIKit.Button()

    init(
        draft: SwapScreenDraft,
        configuration: ViewControllerConfiguration,
        theme: SwapAssetViewControllerTheme = .init()
    ) {
        self.draft = draft
        self.theme = theme
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
        bindNavigationItemTitle()
    }

    override func prepareLayout() {
        super.prepareLayout()
        addSwapAction()
    }
}

extension SwapAssetViewController {
    private func addBarButtons() {
        let infoBarButtonItem = ALGBarButtonItem(kind: .info) {
            [weak self] in
            guard let self = self else {
                return
            }

        }

        rightBarButtonItems = [infoBarButtonItem]
    }

    private func bindNavigationItemTitle() {
        title = "title-swap".localized
    }
}

extension SwapAssetViewController {
    private func addSwapAction() {
        swapActionView.customizeAppearance(theme.swapAction)

        contentView.addSubview(swapActionView)
        swapActionView.contentEdgeInsets = theme.swapActionContentEdgeInsets
        swapActionView.snp.makeConstraints {
            $0.leading == theme.swapActionEdgeInsets.leading
            $0.trailing == theme.swapActionEdgeInsets.trailing
            $0.bottom == theme.swapActionEdgeInsets.bottom
         }

        swapActionView.addTouch(
             target: self,
             action: #selector(swap)
         )
    }
}

extension SwapAssetViewController {
    @objc
    private func swap() {
        eventHandler?(.swap)
    }
}

extension SwapAssetViewController {
    enum Event {
        case swap
    }
}
