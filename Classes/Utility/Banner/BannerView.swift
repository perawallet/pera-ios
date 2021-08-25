// Copyright 2019 Algorand, Inc.

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
//   BannerView.swift

import Foundation
import Macaroon
import UIKit

final class BannerView: View, ViewModelBindable {
    var completion: (() -> Void)? {
        didSet {
            addBannerTapGesture()
        }
    }

    private var style: Style?

    private lazy var horizontalStackView = UIStackView()
    private lazy var verticalStackView = VStackView()
    private lazy var titleLabel = Label()
    private lazy var messageLabel = Label()
    private lazy var iconView = UIImageView()

    func customize(
        for mode: Style
    ) {
        self.style = mode

        switch mode {
        case .info:
            customizeAppearance(
                BannerViewInfoStyleSheet()
            )
        case .error:
            customizeAppearance(
                BannerViewErrorStyleSheet()
            )
        }
        prepareLayout(
            BannerViewCommonLayoutSheet()
        )
    }

    func customizeAppearance(
        _ styleSheet: BannerViewStyleSheet
    ) {
        customizeAppearance(
            styleSheet.background
        )
        customizeTitleAppearance(
            styleSheet
        )
        customizeMessageAppearance(
            styleSheet
        )
        customizeIconAppearance(
            styleSheet
        )

        drawAppearance(
            shadow: styleSheet.backgroundShadow
        )
    }

    func prepareLayout(
        _ layoutSheet: BannerViewLayoutSheet
    ) {
        addHorizontalStackView(
            layoutSheet
        )

        switch style {
        case .info:
            addVerticalStackView(
                layoutSheet
            )
            addTitle(
                layoutSheet
            )
        case .error:
            addIcon(
                layoutSheet
            )
            addVerticalStackView(
                layoutSheet
            )
            addTitle(
                layoutSheet
            )
            addMessage(
                layoutSheet
            )
        case .none:
            return
        }
    }

    func bindData(
        _ viewModel: BannerViewModel?
    ) {
        bindTitle(
            viewModel
        )
        bindMessage(
            viewModel
        )
        bindIcon(
            viewModel
        )
    }
}

extension BannerView {
    private func addBannerTapGesture() {
        addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapBanner))
        )
    }

    @objc
    private func didTapBanner() {
        completion?()
    }
}

extension BannerView {
    private func customizeTitleAppearance(
        _ styleSheet: BannerViewStyleSheet
    ) {
        titleLabel.customizeAppearance(
            styleSheet.title
        )
    }

    private func customizeMessageAppearance(
        _ styleSheet: BannerViewStyleSheet
    ) {
        guard let message = styleSheet.message else {
            messageLabel.isHidden = true
            return
        }

        messageLabel.customizeAppearance(
            message
        )
    }

    private func customizeIconAppearance(
        _ styleSheet: BannerViewStyleSheet
    ) {
        guard let icon = styleSheet.icon else {
            iconView.isHidden = true
            return
        }

        iconView.customizeAppearance(
            icon
        )
    }
}

extension BannerView {
    private func addHorizontalStackView(
        _ layoutSheet: BannerViewLayoutSheet
    ) {
        addSubview(
            horizontalStackView
        )

        horizontalStackView.spacing = layoutSheet.horizontalStackViewSpacing
        horizontalStackView.distribution = .fillProportionally
        horizontalStackView.alignment = .top

        horizontalStackView.snp.makeConstraints {
            $0.setPaddings(
                layoutSheet.horizontalStackViewPaddings
            )
        }
    }

    private func addVerticalStackView(
        _ layoutSheet: BannerViewLayoutSheet
    ) {
        horizontalStackView.addArrangedSubview(
            verticalStackView
        )

        verticalStackView.spacing = layoutSheet.verticalStackViewSpacing
    }

    private func addTitle(
        _ layoutSheet: BannerViewLayoutSheet
    ) {
        verticalStackView.addArrangedSubview(
            titleLabel
        )
    }

    private func addMessage(
        _ layoutSheet: BannerViewLayoutSheet
    ) {
        verticalStackView.addArrangedSubview(
            messageLabel
        )
    }

    private func addIcon(
        _ layoutSheet: BannerViewLayoutSheet
    ) {
        horizontalStackView.addArrangedSubview(
            iconView
        )
        
        iconView.snp.makeConstraints {
            $0.fitToSize(layoutSheet.iconSize)
        }
    }
}

extension BannerView {
    private func bindTitle(
        _ viewModel: BannerViewModel?
    ) {
        titleLabel.editText = viewModel?.title
    }

    private func bindMessage(
        _ viewModel: BannerViewModel?
    ) {
        messageLabel.editText = viewModel?.message
    }

    private func bindIcon(
        _ viewModel: BannerViewModel?
    ) {
        iconView.image = viewModel?.icon?.image
    }
}

extension BannerView {
    enum Style {
        case info
        case error
    }
}
