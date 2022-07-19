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

//   VerificationInfoHeaderView.swift

import Foundation
import UIKit
import MacaroonUIKit

final class VerificationInfoHeaderView:
    View,
    ViewModelBindable {
    private lazy var closeButton = MacaroonUIKit.Button()
    private lazy var backgroundView = ImageView()
    private lazy var logoView = ImageView()

    func customize(_ theme: VerificationInfoHeaderViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addCloseButton(theme)
        addBackgroundView(theme)
        addLogoView(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension VerificationInfoHeaderView {
    func bindData(_ viewModel: VerificationInfoHeaderViewModel?) {
        backgroundView.image = viewModel?.backgroundImage?.uiImage
        logoView.image = viewModel?.logoImage?.uiImage
    }
}

extension VerificationInfoHeaderView {
    private func addCloseButton(_ theme: VerificationInfoHeaderViewTheme) {
        closeButton.customizeAppearance(theme.closeButton)

        addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.closeButtonTopPadding)
            $0.leading.equalToSuperview().inset(theme.closeButtonLeadingPadding)
            $0.fitToSize(theme.closeButtonSize)
        }
    }
    
    private func addBackgroundView(_ theme: VerificationInfoHeaderViewTheme) {
        backgroundView.customizeAppearance(theme.backgroundImage)

        addSubview(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addLogoView(_ theme: VerificationInfoHeaderViewTheme) {
        logoView.customizeAppearance(theme.logoImage)

        addSubview(logoView)
        logoView.snp.makeConstraints {
            $0.bottom.top.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
    }
}
