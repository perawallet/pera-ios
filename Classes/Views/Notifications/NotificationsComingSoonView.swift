//
//  NotificationsComingSoonView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class NotificationsComingSoonView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var comingSoonButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-notification-coming-soon"))
            .withTitle("notifications-coming-soon-title".localized)
            .withTitleColor(SharedColors.tertiaryText)
            .withFont(UIFont.font(withWeight: .bold(size: 12.0)))
    }()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .bold(size: 28.0)))
            .withTextColor(SharedColors.primaryText)
            .withText("notifications-title".localized)
            .withLine(.single)
            .withAlignment(.center)
    }()
    
    private lazy var detailLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(SharedColors.gray800)
            .withText("notifications-coming-soon-detail-text".localized)
            .withLine(.contained)
            .withAlignment(.center)
    }()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupComingSoonButtonLayout()
        setupDetailLabelLayout()
    }
}

extension NotificationsComingSoonView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupComingSoonButtonLayout() {
        addSubview(comingSoonButton)
        
        comingSoonButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(layout.current.buttonBottomInset)
            make.width.equalTo(layout.current.comingSoonWidth)
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.detailLabelHorizontalInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.detailLabelVerticalInset)
        }
    }
}

extension NotificationsComingSoonView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let buttonBottomInset: CGFloat = -20.0
        let comingSoonWidth: CGFloat = 114.0
        let detailLabelHorizontalInset: CGFloat = 32.0
        let detailLabelVerticalInset: CGFloat = 12.0
    }
}
