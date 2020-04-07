//
//  VerifiedAssetInformationView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class VerifiedAssetInformationView: BaseView {
    
    weak var delegate: VerifiedAssetInformationViewDelegate?
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var labelTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(notifyDelegateToOpenFeedback(_:))
    )
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 16.0)))
            .withTextColor(SharedColors.purple)
            .withAlignment(.left)
            .withText("verified-asset-information-title".localized)
            .withLine(.contained)
    }()
    
    private lazy var verifiedImageView = UIImageView(image: img("icon-verified"))
    
    private lazy var informationLabel: UILabel = {
        let label = UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .regular(size: 14.0)))
            .withTextColor(.black)
            .withAlignment(.left)
            .withLine(.contained)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    override func setListeners() {
        informationLabel.addGestureRecognizer(labelTapGestureRecognizer)
    }
    
    override func configureAppearance() {
        backgroundColor = .white
        addInformationTextAttributes()
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupVerifiedImageViewLayout()
        setupInformationLabelLayout()
    }
}

extension VerifiedAssetInformationView {
    @objc
    private func notifyDelegateToOpenFeedback(_ gestureRecognizer: UITapGestureRecognizer) {
        let fullText = "verified-asset-information-text".localized as NSString
        let contactTextRange = fullText.range(of: "verified-asset-information-contact-us".localized)

        if gestureRecognizer.detectTouchForLabel(informationLabel, in: contactTextRange) {
            delegate?.verifiedAssetInformationViewDidTapContactText(self)
        }
    }
}

extension VerifiedAssetInformationView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.titleTopInset)
            make.leading.equalToSuperview().inset(layout.current.titleHorizontalInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.titleHorizontalInset)
        }
    }
    
    private func setupVerifiedImageViewLayout() {
        addSubview(verifiedImageView)
        
        verifiedImageView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(layout.current.imageLeadingOffset)
            make.bottom.equalTo(titleLabel).offset(layout.current.imageBottomOffset)
        }
    }
    
    private func setupInformationLabelLayout() {
        addSubview(informationLabel)
        
        informationLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.informationHorizontalInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.informationVerticalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.informationVerticalInset)
        }
    }
}

extension VerifiedAssetInformationView {
    private func addInformationTextAttributes() {
        let fullText = "verified-asset-information-text".localized
        let doubleCheckText = "verified-asset-double-check".localized
        let contactText = "verified-asset-information-contact-us".localized
        
        let fullAttributedText = NSMutableAttributedString(string: fullText)
        
        let doubleCheckTextRange = (fullText as NSString).range(of: doubleCheckText)
        fullAttributedText.addAttribute(.foregroundColor, value: SharedColors.blue, range: doubleCheckTextRange)
        
        let contactTextRange = (fullText as NSString).range(of: contactText)
        fullAttributedText.addAttribute(.foregroundColor, value: SharedColors.purple, range: contactTextRange)
        fullAttributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: contactTextRange)
        fullAttributedText.addAttribute(.underlineColor, value: SharedColors.purple, range: contactTextRange)
        
        informationLabel.attributedText = fullAttributedText
    }
}

extension VerifiedAssetInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleHorizontalInset: CGFloat = 26.0
        let titleTopInset: CGFloat = 39.0
        let imageLeadingOffset: CGFloat = 10.0
        let imageBottomOffset: CGFloat = -3.0
        let informationHorizontalInset: CGFloat = 25.0
        let informationVerticalInset: CGFloat = 18.0
    }
}

protocol VerifiedAssetInformationViewDelegate: class {
    func verifiedAssetInformationViewDidTapContactText(_ verifiedAssetInformationView: VerifiedAssetInformationView)
}
