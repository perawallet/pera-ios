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

//   ShowMoreView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class ShowMoreView:
    View,
    ViewModelBindable,
    UIInteractable {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .show: TargetActionInteraction()
    ]
    
    private lazy var titleView = Label()
    private lazy var detailView = Label()
    private lazy var showButton = Button()

    func customize(
        _ theme: ShowMoreViewTheme
    ) {
        addTitle(theme)
        addDetail(theme)
        addShow(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
}

extension ShowMoreView {
    private func addTitle(
        _ theme: ShowMoreViewTheme
    ) {
        titleView.customizeAppearance(theme.title)

        addSubview(titleView)
        titleView.fitToVerticalIntrinsicSize()
        titleView.contentEdgeInsets.bottom = theme.spacingBetweenTitleAndDetail
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing <= 0
        }
    }

    private func addDetail(
        _ theme: ShowMoreViewTheme
    ) {
        detailView.customizeAppearance(theme.detail)

        addSubview(detailView)
        detailView.fitToVerticalIntrinsicSize(
            hugging: .defaultLow,
            compression: .required
        )
        detailView.snp.makeConstraints {
            $0.top == titleView.snp.bottom
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func addShow(
        _ theme: ShowMoreViewTheme
    ) {
        showButton.customizeAppearance(theme.showMore)

        addSubview(showButton)
        showButton.fitToIntrinsicSize()
        showButton.snp.makeConstraints {
            $0.top == detailView.snp.bottom + theme.spacingBetweenDetailAndShowMore
            $0.leading == 0
            $0.bottom == 0
            $0.trailing <= 0
        }

        startPublishing(
            event: .show,
            for: showButton
        )
    }
}

extension ShowMoreView {
    func bindData(
        _ viewModel: ShowMoreViewModel?
    ) {
        if let title = viewModel?.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
            titleView.attributedText = nil
        }

        if let detail = viewModel?.detail {
            detail.load(in: detailView)
        } else {
            detailView.text = nil
            detailView.attributedText = nil
        }

        if let textOverflow = viewModel?.showTextOverflow {
            detailView.customizeBaseAppearance(textOverflow: textOverflow)
            detailView.invalidateIntrinsicContentSize()
        }

        if let show = viewModel?.showMore {
            show.load(in: showButton)
        } else {
            showButton.setTitle(nil, for: .normal)
            showButton.setAttributedTitle(nil, for: .normal)
        }
    }

    class func calculatePreferredSize(
        _ viewModel: ShowMoreViewModel?,
        for theme: ShowMoreViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        guard let viewModel = viewModel else {
            return CGSize((size.width, 0))
        }

        let width = size.width
        let titleSize = viewModel.title?.boundingSize(
            multiline: true,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero

        /// <note> Detail label height should be calculated based on the currently displayed text size.
        let detailCurrentlyDisplayedHeight = CGFloat(viewModel.displayedNumberOfDetailTextLines) * theme.detailLineHeight

        let showSize = viewModel.showMore?.boundingSize(
            multiline: false,
            fittingSize: CGSize((width, .greatestFiniteMagnitude))
        ) ?? .zero
        let spacing = theme.spacingBetweenTitleAndDetail + theme.spacingBetweenDetailAndShowMore
        let contentHeight = titleSize.height +
            detailCurrentlyDisplayedHeight +
            showSize.height +
            spacing
        return CGSize((size.width, min(contentHeight.ceil(), size.height)))
    }
}

extension ShowMoreView {
    enum Event {
        case show
    }
}
