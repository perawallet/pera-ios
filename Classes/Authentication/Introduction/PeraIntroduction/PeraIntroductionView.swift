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

//   PeraIntroductionView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class PeraIntroductionView:
    View,
    UIInteractionObservable,
    UIControlInteractionPublisher {
    weak var delegate: PeraIntroductionViewDelegate? /// <todo> Remove delegate

    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .closeScreen: UIControlInteraction()
    ]

    private lazy var theme = PeraInroductionViewTheme()

    private lazy var closeButton = UIButton()

    private lazy var topViewContainer = UIView()
    private lazy var peraLogoImageView = ImageView()
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    private lazy var firstTitleLabel = Label()
    private lazy var secondTitleLabel = Label()
    private lazy var descriptionLabel = Label()
    private lazy var actionButton = MacaroonUIKit.Button()

    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)

        customize(theme)
        linkInteractors()
    }

    func customize(
        _ theme: PeraInroductionViewTheme
    ) {
        scrollView.delegate = self
        addScrollView()
        addContentView()
        addFirstTitleLabel(theme)
        addSecondTitleLabel(theme)
        addDescriptionLabel(theme)
        addActionButton(theme)
        addTopViewContainer(theme)
        addPeraAlgoImageView(theme)
        addCloseButton(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) { }

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) { }

    func linkInteractors() {
        scrollView.delegate = self
    }
}

extension PeraIntroductionView {
    private func addCloseButton(
        _ theme: PeraInroductionViewTheme
    ) {
        closeButton.customizeAppearance(theme.closeButton)

        addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.closeButtonTopPadding)
            $0.leading.equalToSuperview().inset(theme.horizontalPadding)
            $0.fitToSize(theme.closeButtonSize)
        }

        startPublishing(event: .closeScreen, for: closeButton)
    }

    private func addTopViewContainer(
        _ theme: PeraInroductionViewTheme
    ) {
        topViewContainer.customizeAppearance(theme.topViewContainer)

        addSubview(topViewContainer)
        topViewContainer.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.fitToHeight(theme.topContainerMaxHeight)
        }
    }

    private func addPeraAlgoImageView(
        _ theme: PeraInroductionViewTheme
    ) {
        peraLogoImageView.customizeAppearance(theme.peraLogoImageView)

        topViewContainer.addSubview(peraLogoImageView)
        peraLogoImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.fitToSize(theme.peraLogoMaxSize)
        }
    }

    private func addScrollView() {
        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never

        addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addContentView() {
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalToSuperview().inset(safeAreaBottom).priority(.low)
            $0.edges.equalToSuperview()
        }

        scrollView.contentInset.top = theme.topContainerMaxHeight
    }

    private func addFirstTitleLabel(
        _ theme: PeraInroductionViewTheme
    ) {
        firstTitleLabel.customizeAppearance(theme.firstTitleLabel)

        contentView.addSubview(firstTitleLabel)
        firstTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(theme.firstTitleLabelTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addSecondTitleLabel(
        _ theme: PeraInroductionViewTheme
    ) {
        secondTitleLabel.customizeAppearance(theme.secondTitleLabel)

        contentView.addSubview(secondTitleLabel)
        secondTitleLabel.snp.makeConstraints {
            $0.top.equalTo(firstTitleLabel.snp.bottom).offset(theme.secondTitleLabelTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addDescriptionLabel(
        _ theme: PeraInroductionViewTheme
    ) {
        descriptionLabel.customizeAppearance(theme.descriptionLabel)

        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(secondTitleLabel.snp.bottom).offset(theme.descriptionLabelTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.lessThanOrEqualToSuperview().inset(theme.bottomPadding)
        }

        descriptionLabel.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(didTapDescriptionLabel)
            )
        )
    }

    private func addActionButton(
        _ theme: PeraInroductionViewTheme
    ) {
        let containerView = UIView()
        addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.fitToHeight(theme.linearGradientHeight)
        }

        actionButton.contentEdgeInsets = UIEdgeInsets(theme.actionButtonContentEdgeInsets)
        actionButton.draw(corner: theme.actionButtonCorner)
        actionButton.customizeAppearance(theme.actionButton)

        containerView.addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.equalToSuperview().inset(safeAreaBottom + theme.bottomPadding)
        }

        let layer: CAGradientLayer = CAGradientLayer()
        layer.frame.size = CGSize(width: UIScreen.main.bounds.width, height: theme.linearGradientHeight)
        layer.frame.origin = .zero

        let color0 = AppColors.Shared.System.background.uiColor.withAlphaComponent(0).cgColor
        let color1 = AppColors.Shared.System.background.uiColor.cgColor

        layer.colors = [color0, color1]
        containerView.layer.insertSublayer(layer, at: 0)

        startPublishing(event: .closeScreen, for: actionButton)
    }
}

/// <note>: Parallax effect
extension PeraIntroductionView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentY = scrollView.contentOffset.y + scrollView.contentInset.top

        let height = theme.topContainerMaxHeight - contentY

        if height < theme.topContainerMinHeight {
            return
        }

        topViewContainer.snp.updateConstraints {
            $0.fitToHeight(height)
        }

        peraLogoImageView.snp.updateConstraints {
            $0.fitToSize(
                (
                    max(
                        theme.peraLogoMinSize.w,
                        theme.peraLogoMaxSize.w * height / theme.topContainerMaxHeight
                    ),
                    max(
                        theme.peraLogoMinSize.h,
                        theme.peraLogoMaxSize.h * height / theme.topContainerMaxHeight
                    )
                )
            )
        }
    }
}

extension PeraIntroductionView {
    /// <todo>
    /// We need a component/functionality for better handling texts with links.
    @objc
    private func didTapDescriptionLabel(_ recognizer: UITapGestureRecognizer) {
        let fullText = "pera-announcement-description".localized as NSString
        let peraWalletBlog = fullText.range(of: "pera-announcement-description-blog".localized)

        if recognizer.detectTouchForLabel(descriptionLabel, in: peraWalletBlog) {
            delegate?.peraInroductionViewDidTapPeraWalletBlog(self)
        }
    }
}

extension PeraIntroductionView {
    enum Event {
        case closeScreen
    }
}

protocol PeraIntroductionViewDelegate: AnyObject {
    func peraInroductionViewDidTapPeraWalletBlog(_ peraIntroductionView: PeraIntroductionView)
}
