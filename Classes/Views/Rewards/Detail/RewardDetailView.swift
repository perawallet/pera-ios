//
//  RewardDetailView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol RewardDetailViewDelegate: class {
    func rewardDetailViewDidTapFAQLabel(_ rewardDetailView: RewardDetailView)
    func rewardDetailViewDidTapOKButton(_ rewardDetailView: RewardDetailView)
}

class RewardDetailView: BaseView {
    
    private let layout = Layout<LayoutConstants>()

    weak var delegate: RewardDetailViewDelegate?
    
    private lazy var faqLabelTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(didTriggerFAQLabel)
    )
    
    // MARK: Components
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 16.0)))
            .withTextColor(SharedColors.black)
            .withLine(.single)
            .withAlignment(.center)
            .withText("rewards-title".localized)
    }()
    
    private lazy var detailLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 14.0)))
            .withTextColor(SharedColors.darkGray)
            .withLine(.contained)
            .withAlignment(.center)
            .withText("rewards-detail-subtitle".localized)
    }()
    
    private(set) lazy var totalRewardAmountContainerView: RewardAmountContainerView = {
        let view = RewardAmountContainerView()
        view.titleLabel.attributedText = "total-rewards-since-last-transaction-title".localized.attributed([.letterSpacing(1.10)])
        view.titleLabel.textColor = SharedColors.purple
        view.algoIconImageView.tintColor = SharedColors.purple
        view.amountLabel.textColor = SharedColors.purple
        return view
    }()
    
    private lazy var faqLabel: UILabel = {
        let label = UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 14.0)))
            .withTextColor(SharedColors.darkGray)
            .withLine(.contained)
            .withAlignment(.center)
        
        var totalString = "total-rewards-faq-title".localized
        let faqString = "total-rewards-faq".localized
        let range = (totalString as NSString).range(of: faqString)
        let attributedText = NSMutableAttributedString(string: totalString)
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: SharedColors.purple, range: range)
        label.attributedText = attributedText
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var okButton = MainButton(title: "title-ok".localized)
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        layer.cornerRadius = 10.0
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

// MARK: Actions

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
            make.leading.trailing.equalToSuperview().inset(layout.current.detailLabelHorizontalInset)
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
            make.top.equalTo(totalRewardAmountContainerView.snp.bottom).offset(layout.current.labelTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.bottomLabelHorizontalInset)
        }
    }
    
    private func setupOKButtonLayout() {
        addSubview(okButton)
        
        okButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(faqLabel.snp.bottom).offset(layout.current.labelTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
}

extension RewardDetailView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let bottomLabelTopInset: CGFloat = 8.0
        let bottomLabelHorizontalInset: CGFloat = 50.0
        let detailLabelHorizontalInset: CGFloat = 28.0
        let containerHorizontalInset: CGFloat = 25.0
        let buttonHorizontalInset: CGFloat = MainButton.Constants.horizontalInset
        let verticalInset: CGFloat = 20.0
        let labelTopInset: CGFloat = 30.0
    }
}
