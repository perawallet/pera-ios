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

//   MoonpayIntroductionView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class MoonpayIntroductionView:
    View,
    ViewModelBindable,
    UIInteractionObservable,
    UIControlInteractionPublisher {
    private(set) var uiInteractions: [Event: MacaroonUIKit.UIInteraction] = [
        .closeScreen: UIControlInteraction(),
        .buyAlgo: UIControlInteraction()
    ]
    
    private lazy var theme = MoonpayIntroductionViewTheme()
    
    private lazy var topViewContainer = UIView()
    private lazy var moonpayLogoImageView = ImageView()
    private lazy var moonpayBackgroundImageView = ImageView()
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    private lazy var closeButton = UIButton()
    private lazy var titleLabel = Label()
    private lazy var subtitleLabel = Label()
    private lazy var descriptionLabel = Label()
    private lazy var securityLabel = Label()
    private lazy var securityImageView = ImageView()
    private lazy var paymentView = HStackView()
    private lazy var paymentMastercardImageView = ImageView()
    private lazy var paymentVisaImageView = ImageView()
    private lazy var paymentAppleImageView = ImageView()
    private lazy var buyButton = MacaroonUIKit.Button()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        linkInteractors()
    }
    
    func customize(_ theme: MoonpayIntroductionViewTheme) {
        self.theme = theme
        
        addScrollView(theme)
        addContentView()
        addSubtitleLabel(theme)
        addDescriptionLabel(theme)
        addSecurityImageView(theme)
        addSecurityLabel(theme)
        addPaymentView(theme)
        addBuyButton(theme)
        addTopContainerView(theme)
        addMoonpayBackgroundImageView(theme)
        addMoonpayLogoImageView(theme)
        addCloseButton(theme)
        addTitleLabel(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    func bindData(_ viewModel: MoonpayIntroductionViewModel?) {
        moonpayLogoImageView.image = viewModel?.logoImage?.uiImage
        moonpayBackgroundImageView.image = viewModel?.backgroundImage?.uiImage
        titleLabel.editText = viewModel?.title
        subtitleLabel.editText = viewModel?.subtitle
        descriptionLabel.editText = viewModel?.description
        securityImageView.image = viewModel?.securityImage?.uiImage
        securityLabel.editText = viewModel?.security
        paymentMastercardImageView.image = viewModel?.paymentMastercardImage?.uiImage
        paymentVisaImageView.image = viewModel?.paymentVisaImage?.uiImage
        paymentAppleImageView.image = viewModel?.paymentAppleImage?.uiImage
    }
    
    func linkInteractors() {
        scrollView.delegate = self
        
        startPublishing(event: .closeScreen, for: closeButton)
        startPublishing(event: .buyAlgo, for: buyButton)
    }
}

extension MoonpayIntroductionView {
    private func addScrollView(_ theme: MoonpayIntroductionViewTheme){
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentInset.top = theme.topContainerMaxHeight
        
        addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    private func addContentView(){
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.edges.equalToSuperview()
        }
    }
    private func addSubtitleLabel(_ theme: MoonpayIntroductionViewTheme){
        subtitleLabel.customizeAppearance(theme.subtitleLabel)
        
        contentView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(theme.subtitleLabelTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
    private func addDescriptionLabel(_ theme: MoonpayIntroductionViewTheme){
        descriptionLabel.customizeAppearance(theme.descriptionLabel)
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(theme.descriptionLabelTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
    private func addSecurityImageView(_ theme: MoonpayIntroductionViewTheme) {
        contentView.addSubview(securityImageView)
        securityImageView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(theme.securityImageTopPadding)
            $0.leading.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
    private func addSecurityLabel(_ theme: MoonpayIntroductionViewTheme){
        securityLabel.customizeAppearance(theme.securityLabel)
        
        contentView.addSubview(securityLabel)
        securityLabel.snp.makeConstraints {
            $0.centerY.equalTo(securityImageView)
            $0.leading.equalTo(securityImageView.snp.trailing).offset(theme.securityLabelLeadingPadding)
            $0.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
    private func addPaymentView(_ theme: MoonpayIntroductionViewTheme){
        paymentView.distribution = .fillProportionally
        paymentView.alignment = .top
        paymentView.spacing = theme.paymentViewSpacing
        contentView.addSubview(paymentView)
        paymentView.snp.makeConstraints {
            $0.top.equalTo(securityLabel.snp.bottom).offset(theme.paymentViewTopPadding)
            $0.leading.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.lessThanOrEqualToSuperview().inset(safeAreaBottom + theme.paymentViewBottomPadding)
        }
        
        paymentView.addArrangedSubview(paymentMastercardImageView)
        paymentView.addArrangedSubview(paymentVisaImageView)
        paymentView.addArrangedSubview(paymentAppleImageView)
    }
    private func addBuyButton(_ theme: MoonpayIntroductionViewTheme){
        buyButton.contentEdgeInsets = UIEdgeInsets(theme.buttonContentEdgeInsets)
        buyButton.draw(corner: theme.buttonCorner)
        buyButton.customizeAppearance(theme.buyButton)
        
        addSubview(buyButton)
        buyButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.bottom.equalToSuperview().inset(safeAreaBottom + theme.bottomPadding)
        }
    }
    private func addTopContainerView(_ theme: MoonpayIntroductionViewTheme){
        topViewContainer.customizeAppearance(theme.topContainer)
        
        addSubview(topViewContainer)
        topViewContainer.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.fitToHeight(theme.topContainerMaxHeight)
        }
    }
    private func addMoonpayBackgroundImageView(_ theme: MoonpayIntroductionViewTheme) {
        moonpayBackgroundImageView.customizeAppearance(theme.moonpayBackgroundImageView)
        topViewContainer.addSubview(moonpayBackgroundImageView)
        moonpayBackgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
    }
    private func addMoonpayLogoImageView(_ theme: MoonpayIntroductionViewTheme){
        moonpayLogoImageView.customizeAppearance(theme.moonpayLogoImageView)
        
        topViewContainer.addSubview(moonpayLogoImageView)
        moonpayLogoImageView.snp.makeConstraints {
            $0.fitToSize(theme.moonpayLogoMaxSize)
            $0.center.equalToSuperview()
        }
    }
    private func addCloseButton(_ theme: MoonpayIntroductionViewTheme){
        closeButton.customizeAppearance(theme.closeButton)
        
        addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.closeButtonTopPadding)
            $0.leading.equalToSuperview().inset(theme.closeButtonLeadingPadding)
            $0.fitToSize(theme.closeButtonSize)
        }
    }
    private func addTitleLabel(_ theme: MoonpayIntroductionViewTheme){
        titleLabel.customizeAppearance(theme.titleLabel)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.titleTopPadding)
            $0.centerX.equalToSuperview()
        }
    }
}


/// <note>: Parallax effect
extension MoonpayIntroductionView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentY = scrollView.contentOffset.y + scrollView.contentInset.top

        let height = theme.topContainerMaxHeight - contentY

        if height < theme.topContainerMinHeight {
            return
        }

        topViewContainer.snp.updateConstraints {
            $0.fitToHeight(height)
        }
        
        moonpayLogoImageView.snp.updateConstraints {
            $0.fitToSize(
                (
                    max(
                        theme.moonpayLogoMinSize.w,
                        theme.moonpayLogoMaxSize.w * height / theme.topContainerMaxHeight
                    ),
                    max(
                        theme.moonpayLogoMinSize.h,
                        theme.moonpayLogoMaxSize.h * height / theme.topContainerMaxHeight
                    )
                )
            )
        }
    }
}

extension MoonpayIntroductionView {
    enum Event {
        case closeScreen
        case buyAlgo
    }
}
