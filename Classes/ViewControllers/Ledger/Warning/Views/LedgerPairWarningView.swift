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

//
//   LedgerPairWarningView.swift

import UIKit
import MacaroonUIKit

final class LedgerPairWarningView:
    View,
    UIInteractionObservable,
    UIControlInteractionPublisher {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .close: UIControlInteraction(),
    ]

    private lazy var titleLabel = UILabel()
    private lazy var imageView = UIImageView()
    private lazy var subtitleLabel = UILabel()
    private lazy var instructionVerticalStackView = VStackView()
    private lazy var actionButton = Button()

    private lazy var instructions = Instruction.all

    func customize(_ theme: LedgerPairWarningViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addImageView(theme)
        addTitleLabel(theme)
        addSubtitleLabel(theme)
        addInstructionVerticalStackView(theme)
        addActionButton(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: ViewStyle) {}
}

extension LedgerPairWarningView {
    private func addImageView(_ theme: LedgerPairWarningViewTheme) {
        imageView.customizeAppearance(theme.image)

        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(theme.topInset)
        }
    }

    private func addTitleLabel(_ theme: LedgerPairWarningViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(theme.titleTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addSubtitleLabel(_ theme: LedgerPairWarningViewTheme) {
        subtitleLabel.customizeAppearance(theme.subtitle)

        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.descriptionTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addInstructionVerticalStackView(_ theme: LedgerPairWarningViewTheme) {
        addSubview(instructionVerticalStackView)
        instructionVerticalStackView.spacing = theme.instructionSpacing

        instructionVerticalStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(theme.instructionVerticalStackViewTopPadding)
        }

        instructions.forEach {
            let instructionView = InstructionItemView()
            instructionView.customize(theme.largerInstuctionViewTheme)
            instructionView.bindTitle($0.title)
            instructionVerticalStackView.addArrangedSubview(instructionView)
        }
    }

    private func addActionButton(_ theme: LedgerPairWarningViewTheme) {
        actionButton.contentEdgeInsets = UIEdgeInsets(theme.actionButtonContentEdgeInsets)
        actionButton.draw(corner: theme.actionButtonCorner)
        actionButton.customizeAppearance(theme.actionButton)

        addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(instructionVerticalStackView.snp.bottom).offset(theme.buttonTopInset)
            $0.bottom.lessThanOrEqualToSuperview().inset(theme.bottomInset)
        }

        startPublishing(
            event: .close,
            for: actionButton
        )
    }
}

extension LedgerPairWarningView {
    private struct Instruction {
        private let font = Fonts.DMSans.regular.make(15)
        private let lineHeightMultiplier = 1.23

        private(set) var title: EditText?

        init(_ title: String) {
            self.title = .attributedString(
                title
                    .localized
                    .attributed([
                        .font(font),
                        .lineHeightMultiplier(lineHeightMultiplier, font),
                        .paragraph([
                            .lineBreakMode(.byWordWrapping),
                            .lineHeightMultiple(lineHeightMultiplier)
                        ])
                    ])
            )
        }

        static let all = [
            Instruction("ledger-pairing-first-warning-message-first-instruction"),
            Instruction("ledger-pairing-first-warning-message-second-instruction"),
            Instruction("ledger-pairing-first-warning-message-third-instruction"),
            Instruction("ledger-pairing-first-warning-message-fourth-instruction")
        ]
    }
}

extension LedgerPairWarningView {
    enum Event {
        case close
    }
}
