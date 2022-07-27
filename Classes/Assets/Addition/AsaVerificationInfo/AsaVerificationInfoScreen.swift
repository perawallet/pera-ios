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

//   VerificationInfoViewController.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AsaVerificationInfoScreen: ScrollScreen {
    private lazy var theme = AsaVerificationInfoScreenTheme()

    private lazy var illustrationView = ImageView()
    private lazy var closeActionView = MacaroonUIKit.Button()
    private lazy var titleView = Label()
    private lazy var bodyView = Label()
    private lazy var primaryActionView = MacaroonUIKit.Button()

    let configuration: ViewControllerConfiguration

    init(
        configuration: ViewControllerConfiguration
    ) {
        self.configuration = configuration

        super.init()
    }

    override func prepareLayout() {
        super.prepareLayout()

        addIllustration()
        addCloseAction()
        addTitle()
        addBody()
        addPrimaryAction()
    }

    override func setListeners() {
        super.setListeners()

        closeActionView.addTouch(
            target: self,
            action: #selector(didTapCloseAction)
        )

        primaryActionView.addTouch(
            target: self,
            action: #selector(didTapPrimaryAction)
        )
    }

    override func viewWillAppear(
        _ animated: Bool
    ) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(
            true,
            animated: true
        )
    }

    override func customizeScrollAppearance() {
        super.customizeScrollAppearance()

        scrollView.contentInset.top = theme.illustrationMaxHeight
    }

    override func scrollViewDidScroll(
        _ scrollView: UIScrollView
    ) {
        updateIllustrationHeightOnScroll()

        super.scrollViewDidScroll(scrollView)
    }

    override func bindData() {
        super.bindData()

        bindTitle()
        bindBody()
    }
}

extension AsaVerificationInfoScreen {
    @objc
    private func didTapPrimaryAction() {
        open(AlgorandWeb.asaVerificationSupport.link)
    }

    @objc
    private func didTapCloseAction() {
        self.dismiss(animated: true)
    }
}

extension AsaVerificationInfoScreen {
    private func bindTitle() {
        titleView.attributedText = "verification-info-title"
            .localized
            .title1Medium(hasMultilines: false)
    }

    private func bindBody() {
        let bodyText = "verification-info-body".localized
        let attributedBodyText = highlight(
            [
                "verification-info-body-first-highlight".localized,
                "verification-info-body-second-highlight".localized,
                "verification-info-body-third-highlight".localized
            ],
            in: bodyText
        )

        let bodyRange = (bodyText as NSString).range(of: bodyText)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 16
        paragraphStyle.lineHeightMultiple = 1.23
        attributedBodyText.addAttribute(
            NSAttributedString.Key.paragraphStyle,
            value: paragraphStyle,
            range: bodyRange
        )

        bodyView.attributedText = attributedBodyText
    }

    private func highlight(
        _ highlightedTexts: [String],
        in fullText: String
    ) -> NSMutableAttributedString {
        let attributedText = NSMutableAttributedString(
            attributedString: fullText.bodyRegular()
        )

        for highlightedText in highlightedTexts {
            let range = (fullText as NSString).range(of: highlightedText)
            attributedText.addAttribute(
                NSAttributedString.Key.font,
                value: Fonts.DMSans.medium.make(15).uiFont,
                range: range)
        }

        return attributedText
    }
}

extension AsaVerificationInfoScreen {
    private func addIllustration() {
        illustrationView.customizeAppearance(theme.illustration)

        view.addSubview(illustrationView)
        illustrationView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.fitToHeight(theme.illustrationMaxHeight)
        }
    }

    private func addCloseAction() {
        closeActionView.customizeAppearance(theme.closeAction)

        view.addSubview(closeActionView)
        closeActionView.snp.makeConstraints {
            $0.top == theme.closeActionEdgeInsets.top
            $0.leading == theme.closeActionEdgeInsets.leading
            $0.fitToSize(theme.closeActionSize)
        }
    }

    private func addTitle() {
        titleView.customizeAppearance(theme.title)

        contentView.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == theme.titleEdgeInsets.top
            $0.leading == theme.titleEdgeInsets.leading
            $0.trailing == theme.titleEdgeInsets.trailing
        }
    }

    private func addBody() {
        bodyView.customizeAppearance(theme.body)

        contentView.addSubview(bodyView)
        bodyView.snp.makeConstraints {
            $0.top == titleView.snp.bottom + theme.bodyEdgeInsets.top
            $0.leading == theme.bodyEdgeInsets.leading
            $0.bottom == theme.bodyEdgeInsets.bottom
            $0.trailing == theme.bodyEdgeInsets.trailing
        }
    }

    private func addPrimaryAction() {
        primaryActionView.contentEdgeInsets = theme.primaryActionContentEdgeInsets
        primaryActionView.customizeAppearance(theme.primaryAction)

        footerView.addSubview(primaryActionView)
        primaryActionView.snp.makeConstraints {
            $0.top == theme.primaryActionEdgeInsets.top
            $0.leading == theme.primaryActionEdgeInsets.leading
            $0.bottom == theme.primaryActionEdgeInsets.bottom
            $0.trailing == theme.primaryActionEdgeInsets.trailing
        }
    }

    private func updateIllustrationHeightOnScroll() {
        let contentY = scrollView.contentOffset.y + scrollView.contentInset.top

        let height = theme.illustrationMaxHeight - contentY

        if height < theme.illustrationMinHeight {
            return
        }

        illustrationView.snp.updateConstraints {
            $0.fitToHeight(height)
        }
    }
}
