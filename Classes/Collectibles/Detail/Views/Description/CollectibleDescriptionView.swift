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

//   CollectibleDescriptionView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class CollectibleDescriptionView:
    View,
    ViewModelBindable,
    ListReusable {
    weak var delegate: CollectibleDescriptionViewDelegate?

    private lazy var descriptionView = ALGActiveLabel()
    private lazy var toggleTruncationActionView = MacaroonUIKit.Button()

    private var theme: CollectibleDescriptionViewTheme?

    func customize(_ theme: CollectibleDescriptionViewTheme) {
        self.theme = theme

        addDescription(theme)
        addToggleTruncationAction(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ viewModel: CollectibleDescriptionViewModel?) {
        let shouldShowToggleTruncationAction = viewModel?.shouldShowToggleTruncationAction ?? false

        if let description = viewModel?.description {
            description.load(in: descriptionView)

            let isTruncating = viewModel?.isTruncating ?? true
            if let theme,
               isTruncating && shouldShowToggleTruncationAction {
                descriptionView.customizeBaseAppearance(textOverflow: theme.truncatedDescriptionOverflow)
            }
        } else {
            descriptionView.text = nil
            descriptionView.attributedText = nil
        }

        if shouldShowToggleTruncationAction,
           let theme {
            toggleTruncationActionView.customizeAppearance(theme.toggleTruncationAction)
        } else {
            toggleTruncationActionView.resetAppearance()
        }
    }

    class func calculatePreferredSize(
        _ viewModel: CollectibleDescriptionViewModel?,
        for theme: CollectibleDescriptionCellTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let isTruncating = viewModel.isTruncating

        var preferredHeight: CGFloat

        let shouldShowToggleTruncationAction = viewModel.shouldShowToggleTruncationAction

        if isTruncating && shouldShowToggleTruncationAction {
            preferredHeight = viewModel.truncatedDescriptionHeight
        } else {
            preferredHeight = viewModel.fullDescriptionHeight
        }

        if shouldShowToggleTruncationAction {
            preferredHeight +=
                theme.context.toggleTruncationActionContentEdgeInsets.vertical +
                theme.toggleTruncationActionFont.lineHeight
        }
        return CGSize((size.width, min(preferredHeight.ceil(), size.height)))
    }
}

extension CollectibleDescriptionView {
    private func addDescription(_ theme: CollectibleDescriptionViewTheme) {
        descriptionView.customize { label in
            label.customizeAppearance(theme.description)
            label.enabledTypes = [.url]
            label.URLColor = theme.descriptionURLColor.uiColor
            label.handleURLTap {
                [unowned self] url in
                self.delegate?.collectibleDescriptionViewDidTapURL(self, url: url)
            }
        }

        addSubview(descriptionView)
        descriptionView.fitToVerticalIntrinsicSize()
        descriptionView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addToggleTruncationAction(_ theme: CollectibleDescriptionViewTheme) {
        toggleTruncationActionView.customizeAppearance(theme.toggleTruncationAction)

        addSubview(toggleTruncationActionView)
        toggleTruncationActionView.contentEdgeInsets = theme.toggleTruncationActionContentEdgeInsets
        toggleTruncationActionView.snp.makeConstraints {
            $0.top == descriptionView.snp.bottom
            $0.leading == 0
            $0.bottom == 0
            $0.trailing <= 0
        }

        toggleTruncationActionView.addTouch(
            target: self,
            action: #selector(toggleBodyTruncation)
        )
    }
}

extension CollectibleDescriptionView {
    private func updateDescriptionWhenToggleTruncationDidChange() {
        guard let theme = theme else { return }

        let isTruncated = !toggleTruncationActionView.isSelected
        let textOverflow = isTruncated ? theme.truncatedDescriptionOverflow : theme.fullDescriptionOverflow
        descriptionView.customizeBaseAppearance(textOverflow: textOverflow)
    }
}

extension CollectibleDescriptionView {
    @objc
    private func toggleBodyTruncation() {
        toggleTruncationActionView.isSelected.toggle()

        updateDescriptionWhenToggleTruncationDidChange()

        publishTruncationChange()
    }

    private func publishTruncationChange() {
        let isTruncated = !toggleTruncationActionView.isSelected

        if isTruncated {
            delegate?.collectibleDescriptionViewDidShowLess(self)
        } else {
            delegate?.collectibleDescriptionViewDidShowMore(self)
        }
    }
}

protocol CollectibleDescriptionViewDelegate: AnyObject {
    func collectibleDescriptionViewDidTapURL(_ view: CollectibleDescriptionView, url: URL)
    func collectibleDescriptionViewDidShowMore(_ view: CollectibleDescriptionView)
    func collectibleDescriptionViewDidShowLess(_ view: CollectibleDescriptionView)
}
