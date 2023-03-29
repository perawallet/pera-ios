// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AlgorandSecureBackupImportFileView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AlgorandSecureBackupImportFileView:
    View,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .performClick: GestureInteraction()
    ]

    private lazy var stateBackgroundView = TripleShadowView()
    private lazy var stateImageView = UIImageView()
    private lazy var titleView = UILabel()
    private lazy var subtitleView = UILabel()
    private lazy var actionView = UIButton()

    func customize(_ theme: AlgorandSecureBackupImportFileViewTheme) {
        draw(corner: Corner(radius: 8))

        addBackground(theme)
        addStateBackground(theme)
        addStateImage(theme)
        addTitle(theme)
        addSubtitle(theme)
        addAction(theme)

        startPublishing(
            event: .performClick,
            for: self
        )

        startPublishing(
            event: .performClick,
            for: actionView
        )
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ viewModel: AlgorandSecureBackupImportFileViewModel?) {
        if let style = viewModel?.imageStyle {
            stateImageView.customizeAppearance(style)
        }

        let image = viewModel?.image
        image?.load(in: stateImageView)

        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }

        if let subtitle = viewModel?.subtitle {
            subtitle.load(in: subtitleView)
        } else {
            subtitleView.text = nil
            subtitleView.attributedText = nil
        }

        let isActionVisible = viewModel?.isActionVisible ?? false
        actionView.isHidden = !isActionVisible

        if let style = viewModel?.actionTheme {
            actionView.customizeAppearance(style)
        }
    }
}

extension AlgorandSecureBackupImportFileView {
    private func addBackground(_ theme: AlgorandSecureBackupImportFileViewTheme) {
        customizeAppearance(theme.background)
    }

    private func addStateBackground(_ theme: AlgorandSecureBackupImportFileViewTheme) {
        stateBackgroundView.drawAppearance(shadow: theme.stateFirstShadow)
        stateBackgroundView.drawAppearance(secondShadow: theme.stateSecondShadow)
        stateBackgroundView.drawAppearance(thirdShadow: theme.stateThirdShadow)

        addSubview(stateBackgroundView)
        stateBackgroundView.snp.makeConstraints {
            $0.top == theme.stateTopInset
            $0.centerX == 0
            $0.fitToSize(theme.stateSize)
        }
    }

    private func addStateImage(_ theme: AlgorandSecureBackupImportFileViewTheme) {
        stateBackgroundView.addSubview(stateImageView)
        stateImageView.snp.makeConstraints {
            $0.center == 0
            $0.fitToSize((24, 24))
        }
    }

    private func addTitle(_ theme: AlgorandSecureBackupImportFileViewTheme) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == stateBackgroundView.snp.bottom + theme.spacingBetweenStateAndTitle
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addSubtitle(_ theme: AlgorandSecureBackupImportFileViewTheme) {
        subtitleView.customizeAppearance(theme.subtitle)

        addSubview(subtitleView)
        subtitleView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndSubtitle
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addAction(_ theme: AlgorandSecureBackupImportFileViewTheme) {
        actionView.customizeAppearance(theme.action)

        addSubview(actionView)
        actionView.snp.makeConstraints {
            $0.bottom == theme.actionBottomInset
            $0.centerX == 0
        }
    }
}

extension AlgorandSecureBackupImportFileView {
    enum Event {
        case performClick
    }
}
