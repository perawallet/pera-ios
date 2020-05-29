//
//  RewardView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 28.08.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class RewardTotalAmountView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var algosImageView = UIImageView(image: img("icon-algo-gray", isTemplate: true))

    private lazy var rewardLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(SharedColors.detailText)
            .withLine(.single)
            .withAlignment(.left)
    }()
    
    private lazy var infoImageView = UIImageView(image: img("icon-info-green"))
    
    override func configureAppearance() {
        backgroundColor = SharedColors.gray50
        algosImageView.tintColor = SharedColors.gray300
        layer.cornerRadius = 12.0
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    override func prepareLayout() {
        setupInfoImageViewLayout()
        setupAlgosImageViewLayout()
        setupRewardLabelLayout()
    }
}

extension RewardTotalAmountView {
    private func setupInfoImageViewLayout() {
        addSubview(infoImageView)
        
        infoImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
            make.size.equalTo(layout.current.imageSize)
        }
    }
    
    private func setupAlgosImageViewLayout() {
        addSubview(algosImageView)
        
        algosImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalTo(infoImageView)
            make.size.equalTo(layout.current.algoSize)
        }
    }
    
    private func setupRewardLabelLayout() {
        addSubview(rewardLabel)
        
        rewardLabel.snp.makeConstraints { make in
            make.leading.equalTo(algosImageView.snp.trailing).offset(layout.current.titleLeadingInset)
            make.trailing.equalTo(infoImageView.snp.leading).offset(-layout.current.titleLeadingInset)
            make.centerY.equalTo(infoImageView)
        }
    }
}

extension RewardTotalAmountView {
    func setReward(amount: String) {
        let fullString = "total-rewards-full-title" .localized(params: amount)
        let attributedPart = "total-rewards-partial-title".localized(params: amount)
        let attributedRewardText = NSMutableAttributedString(attributedString: fullString.attributed([.lineSpacing(1.2)]))
        let range = (fullString as NSString).range(of: attributedPart)
        attributedRewardText.addAttribute(.foregroundColor, value: SharedColors.primaryText, range: range)
        rewardLabel.attributedText = attributedRewardText
        rewardLabel.lineBreakMode = .byTruncatingTail
    }
}

extension RewardTotalAmountView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 15.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
        let algoSize = CGSize(width: 20.0, height: 20.0)
        let horizontalInset: CGFloat = 16.0
        let titleLeadingInset: CGFloat = 4.0
    }
}
