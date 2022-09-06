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

//   SetSlippageToleranceScreen.swift

import Foundation
import MacaroonUIKit
import MacaroonForm
import MacaroonBottomSheet
import SwiftUI

final class SetSlippageToleranceScreen:
    ScrollScreen,
    BottomSheetScrollPresentable {
    var modalHeight: ModalHeight {
        return .compressed
    }

    private let theme: SetSlippageToleranceScreenTheme

    private lazy var contextView = SelectorInputView()

    init(
        theme: SetSlippageToleranceScreenTheme = .init()
    ) {
        self.theme = theme
        super.init()
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        bindNavigationItemTitle()
    }

    override func prepareLayout() {
        super.prepareLayout()

        addBackground(theme)
        addContext(theme)
    }
}

extension SetSlippageToleranceScreen {
    private func bindNavigationItemTitle() {
        navigationItem.largeTitleDisplayMode = .never
        title = "swap-slippage-title".localized
    }
}

extension SetSlippageToleranceScreen {
    private func addBackground(_ theme: SetSlippageToleranceScreenTheme) {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    private func addContext(_ theme: SetSlippageToleranceScreenTheme) {
        contextView.customize(theme.contextView)

        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
