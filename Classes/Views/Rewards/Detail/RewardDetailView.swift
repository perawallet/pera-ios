//
//  RewardDetailView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class RewardDetailView: BaseView {
    
    private let layout = Layout<LayoutConstants>()

    weak var delegate: RewardDetailViewDelegate?
    
    private lazy var faqLabelTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(didTriggerFAQLabel)
    )
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTextColor(SharedColors.primaryText)
            .withLine(.single)
            .withAlignment(.center)
            .withText("rewards-title".localized)
    }()
    
    private lazy var detailLabel: UILabel = {
        UILabel()
            .withAttributedText("rewards-detail-subtitle".localized.attributed([.lineSpacing(1.2)]))
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(SharedColors.primaryText)
            .withLine(.contained)
            .withAlignment(.center)
    }()
    
    private(set) lazy var totalRewardAmountContainerView = RewardAmountContainerView()
    
    private lazy var faqLabel: UILabel = {
        let label = UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(SharedColors.primaryText)
            .withLine(.contained)
            .withAlignment(.center)
        
        var totalString = "total-rewards-faq-title".localized
        let faqString = "total-rewards-faq".localized
        let range = (totalString as NSString).range(of: faqString)
        let attributedText = NSMutableAttributedString(string: totalString)
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: SharedColors.tertiaryText, range: range)
        label.attributedText = attributedText
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var okButton = MainButton(title: "title-ok".localized)
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func setListeners() {
        faqLabel.addGestureRecognizer(faqLabelTapGestureRecognizer)
        okButton.addTarget(self, action: #selector(notifyDelegateToOKButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupDetailLabelLayout()
        setupTotalRewardAmountContainerViewLayout()
        setupFAQLabelLayout()
        setupOKButtonLayout()
    }
}

extension RewardDetailView {
    @objc
    private func notifyDelegateToOKButtonTapped() {
        delegate?.rewardDetailViewDidTapOKButton(self)
    }
    
    @objc
    private func didTriggerFAQLabel() {
        delegate?.rewardDetailViewDidTapFAQLabel(self)
    }
}

extension RewardDetailView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.labelTopInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.verticalInset)
        }
    }
    
    private func setupTotalRewardAmountContainerViewLayout() {
        addSubview(totalRewardAmountContainerView)
        
        totalRewardAmountContainerView.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(layout.current.verticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.containerHorizontalInset)
        }
    }
    
    private func setupFAQLabelLayout() {
        addSubview(faqLabel)
        
        faqLabel.snp.makeConstraints { make in
            make.top.equalTo(totalRewardAmountContainerView.snp.bottom).offset(layout.current.verticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupOKButtonLayout() {
        addSubview(okButton)
        
        okButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(faqLabel.snp.bottom).offset(layout.current.verticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset + safeAreaBottom)
        }
    }
}

extension RewardDetailView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let labelTopInset: CGFloat = 16.0
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 28.0
        let containerHorizontalInset: CGFloat = 32.0
        let bottomInset: CGFloat = 16.0
    }
}

protocol RewardDetailViewDelegate: class {
    func rewardDetailViewDidTapFAQLabel(_ rewardDetailView: RewardDetailView)
    func rewardDetailViewDidTapOKButton(_ rewardDetailView: RewardDetailView)
}
