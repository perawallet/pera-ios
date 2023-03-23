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

//   AssetOptInListNextErrorView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AssetOptInListNextErrorView:
    View,
    ViewModelBindable,
    UIInteractable,
    ListReusable {
    private lazy var bodyView: UILabel = .init()
    private lazy var retryActionView: UIButton = .init()

    var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .retry: TargetActionInteraction()
    ]

    init(_ theme: AssetOptInListNextErrorViewTheme = .init()) {
        super.init(frame: .zero)
        addUI(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension AssetOptInListNextErrorView {
    func bindData(_ viewModel: AssetOptInListNextErrorViewModel?) {
        if let body = viewModel?.body {
            body.load(in: bodyView)
        } else {
            bodyView.text = nil
            bodyView.attributedText = nil
        }
    }

    static func calculatePreferredSize(
        _ viewModel: AssetOptInListNextErrorViewModel?,
        for theme: AssetOptInListNextErrorViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = size.width
        let bodySize = viewModel?.body?.boundingSize(
            multiline: true,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let retryActionHeight =
            (theme.retryAction.font?.uiFont.lineHeight ?? 0) +
            theme.retryActionContentEdgeInsets.vertical
        let preferredHeight =
            theme.contentVerticalEdgeInsets.top +
            bodySize.height +
            theme.spacingBetweenBodyAndRetryAction +
            retryActionHeight +
            theme.contentVerticalEdgeInsets.bottom
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension AssetOptInListNextErrorView {
    private func addUI(_ theme: AssetOptInListNextErrorViewTheme) {
        addBody(theme)
        addRetryAction(theme)
    }

    private func addBody(_ theme: AssetOptInListNextErrorViewTheme) {
        bodyView.customizeAppearance(theme.body)

        addSubview(bodyView)
        bodyView.fitToVerticalIntrinsicSize()
        bodyView.snp.makeConstraints {
            $0.top == theme.contentVerticalEdgeInsets.top
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addRetryAction(_ theme: AssetOptInListNextErrorViewTheme) {
        retryActionView.customizeAppearance(theme.retryAction)

        addSubview(retryActionView)
        retryActionView.contentEdgeInsets = theme.retryActionContentEdgeInsets
        retryActionView.snp.makeConstraints {
            $0.centerX == 0
            $0.top == bodyView.snp.bottom + theme.spacingBetweenBodyAndRetryAction
            $0.leading >= 0
            $0.bottom == theme.contentVerticalEdgeInsets.bottom
            $0.trailing <= 0
        }

        startPublishing(
            event: .retry,
            for: retryActionView
        )
    }
}

extension AssetOptInListNextErrorView {
    enum Event {
        case retry
    }
}
