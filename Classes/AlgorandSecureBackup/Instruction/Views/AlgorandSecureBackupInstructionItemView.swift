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

//   AlgorandSecureBackupInstructionItemView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AlgorandSecureBackupInstructionItemView:
    View,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .performHyperlinkAction: UIBlockInteraction()
    ]

    private lazy var numberBackgroundView = TripleShadowView()
    private lazy var numberView = UILabel()
    private lazy var contentView = UIView()
    private lazy var titleView = UILabel()
    private lazy var subtitleView = ALGActiveLabel()

    func customize(_ theme: AlgorandSecureBackupInstructionItemViewTheme) {
        addNumber(theme)
        addContent(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ viewModel: AlgorandSecureBackupInstructionItemViewModel?) {
        if let number = viewModel?.number {
            number.load(in: numberView)
        } else {
            numberView.text = nil
            numberView.attributedText = nil
        }

        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }

        if let subtitle = viewModel?.subtitle {
            if let highlightedText = viewModel?.subtitle.highlightedText {
                let hyperlink: ALGActiveType = .word(highlightedText.text)
                subtitleView.attachHyperlink(
                    hyperlink,
                    to: subtitle.text,
                    attributes: highlightedText.attributes
                ) {
                    [unowned self] in
                    let interaction = self.uiInteractions[.performHyperlinkAction]
                    interaction?.publish()
                }
                return
            }

            subtitle.text.load(in: subtitleView)
        } else {
            subtitleView.text = nil
            subtitleView.attributedText = nil
        }
    }
}

extension AlgorandSecureBackupInstructionItemView {
    private func addNumber(_ theme: AlgorandSecureBackupInstructionItemViewTheme) {
        numberBackgroundView.drawAppearance(shadow: theme.numberFirstShadow)
        numberBackgroundView.drawAppearance(secondShadow: theme.numberSecondShadow)
        numberBackgroundView.drawAppearance(thirdShadow: theme.numberThirdShadow)

        addSubview(numberBackgroundView)
        numberBackgroundView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.fitToSize(theme.numberSize)
        }

        numberBackgroundView.addSubview(numberView)
        numberView.customizeAppearance(theme.number)
        numberView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func addContent(_ theme: AlgorandSecureBackupInstructionItemViewTheme) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top == 0
            $0.leading == numberBackgroundView.snp.trailing + theme.spacingBetweenNumberAndContent
            $0.trailing == 0
            $0.bottom == 0
        }

        addTitle(theme)
        addSubtitle(theme)
    }

    private func addTitle(_ theme: AlgorandSecureBackupInstructionItemViewTheme) {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addSubtitle(_ theme: AlgorandSecureBackupInstructionItemViewTheme) {
        subtitleView.customizeAppearance(theme.subtitle)

        contentView.addSubview(subtitleView)
        subtitleView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.spacingBetweenTitleAndSubtitle
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}

extension AlgorandSecureBackupInstructionItemView {
    enum Event {
        case performHyperlinkAction
    }
}
