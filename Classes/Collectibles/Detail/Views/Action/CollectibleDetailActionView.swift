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

//   CollectibleDetailActionView.swift

import UIKit
import MacaroonUIKit

final class CollectibleDetailActionView:
    View,
    ListReusable,
    ViewModelBindable,
    UIInteractionObservable,
    UIControlInteractionPublisher {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .performSend: UIControlInteraction(),
        .performShare: UIControlInteraction()
    ]

    private lazy var titleLabel = UILabel()
    private lazy var subtitleLabel = UILabel()
    private lazy var sendButton = Button(.imageAtLeft(spacing: 12))
    private lazy var shareButton = Button(.imageAtLeft(spacing: 12))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setListeners()
    }

    func customize(
        _ theme: CollectibleDetailActionViewTheme
    ) {
        addTitleLabel(theme)
        addSubtitleLabel(theme)
        addShareButton(theme)
        addSendButton(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func setListeners() {
        startPublishing(
            event: .performSend,
            for: sendButton
        )

        startPublishing(
            event: .performShare,
            for: shareButton
        )
    }
}

extension CollectibleDetailActionView {
    private func addTitleLabel(_ theme: CollectibleDetailActionViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top == theme.topInset
            $0.leading.trailing == 0
        }
    }

    private func addSubtitleLabel(_ theme: CollectibleDetailActionViewTheme) {
        subtitleLabel.customizeAppearance(theme.subtitle)

        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.top == titleLabel.snp.bottom + theme.subtitleTopOffset
            $0.leading.trailing == 0
        }
    }

    private func addShareButton(_ theme: CollectibleDetailActionViewTheme) {
        shareButton.customize(theme.share)
        shareButton.bindData(
            ButtonCommonViewModel(
                title: "collectible-detail-share".localized,
                iconSet: [.normal("icon-share")])
        )

        addSubview(shareButton)
        shareButton.snp.makeConstraints {
            $0.bottom.trailing == 0
            $0.top == subtitleLabel.snp.bottom + theme.buttonTopOffset
            $0.leading.equalToSuperview().priority(.low)
            $0.height == theme.buttonHeight
        }

        shareButton.addSeparator(theme.separator, padding: theme.buttonBottomInset)
    }

    private func addSendButton(_ theme: CollectibleDetailActionViewTheme) {
        sendButton.customize(theme.send)
        sendButton.bindData(
            ButtonCommonViewModel(
                title: "title-send".localized,
                iconSet: [.normal("icon-arrow-up")])
        )

        addSubview(sendButton)
        sendButton.snp.makeConstraints {
            $0.leading == 0
            $0.top == shareButton
            $0.trailing == shareButton.snp.leading - theme.sendButtonTrailingOffset
            $0.height == shareButton.snp.height
        }
    }
}

extension CollectibleDetailActionView {
    func bindData(_ viewModel: CollectibleDetailActionViewModel?) {
        guard let viewModel = viewModel else {
            return
        }

        titleLabel.editText = viewModel.title
        subtitleLabel.editText = viewModel.subtitle

        if !viewModel.canTransfer {
            sendButton.removeFromSuperview()
        }
    }

    class func calculatePreferredSize(
        _ viewModel: CollectibleDetailActionViewModel?,
        for theme: CollectibleDetailActionViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let titleSize = viewModel.title.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let subtitleSize = viewModel.subtitle.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        )
        let buttonHeight = theme.buttonHeight
        let verticalSpacing =
            theme.topInset +
            theme.subtitleTopOffset +
            theme.buttonTopOffset +
            theme.buttonBottomInset
        let contentHeight =
            titleSize.height +
            subtitleSize.height +
            buttonHeight +
            verticalSpacing

        return CGSize((size.width, min(contentHeight.ceil(), size.height)))
    }
}

extension CollectibleDetailActionView {
    enum Event {
        case performSend
        case performShare
    }
}
