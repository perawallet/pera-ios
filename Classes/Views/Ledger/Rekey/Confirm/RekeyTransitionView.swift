//
//  RekeyTransitionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 3.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class RekeyTransitionView: BaseView {
    
    override var intrinsicContentSize: CGSize {
        return layout.current.contentSize
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var oldTitleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(SharedColors.gray500)
            .withLine(.single)
            .withAlignment(.center)
    }()
    
    private lazy var oldValueLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(SharedColors.primaryText)
            .withLine(.single)
            .withAlignment(.center)
    }()
    
    private lazy var arrowImageView = UIImageView(image: img("icon-arrow-right"))
    
    private lazy var newTitleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(SharedColors.gray500)
            .withLine(.single)
            .withAlignment(.center)
    }()
    
    private lazy var newValueLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(SharedColors.primaryText)
            .withLine(.single)
            .withAlignment(.center)
    }()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
        layer.cornerRadius = 12.0
        applySmallShadow()
    }
    
    override func prepareLayout() {
        setupArrowImageViewLayout()
        setupOldTitleLabelLayout()
        setupOldValueLabelLayout()
        setupNewTitleLabelLayout()
        setupNewValueLabelLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateShadowLayoutWhenViewDidLayoutSubviews(cornerRadius: 12.0)
    }
}

extension RekeyTransitionView {
    private func setupArrowImageViewLayout() {
        addSubview(arrowImageView)
        
        arrowImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(layout.current.iconSize)
        }
    }
    
    private func setupOldTitleLabelLayout() {
        addSubview(oldTitleLabel)
        
        oldTitleLabel.snp.makeConstraints { make in
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-layout.current.arrowOffset)
            make.bottom.equalTo(arrowImageView.snp.top).inset(layout.current.titleBottomInset)
            make.leading.greaterThanOrEqualToSuperview()
        }
    }
    
    private func setupOldValueLabelLayout() {
        addSubview(oldValueLabel)
        
        oldValueLabel.snp.makeConstraints { make in
            make.top.equalTo(oldTitleLabel.snp.bottom).offset(layout.current.topInset)
            make.centerX.equalTo(oldTitleLabel)
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualTo(arrowImageView.snp.leading)
        }
    }
    
    private func setupNewTitleLabelLayout() {
        addSubview(newTitleLabel)
        
        newTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(oldTitleLabel)
            make.leading.equalTo(arrowImageView.snp.trailing).offset(layout.current.arrowOffset)
            make.trailing.lessThanOrEqualToSuperview()
        }
    }
    
    private func setupNewValueLabelLayout() {
        addSubview(newValueLabel)
        
        newValueLabel.snp.makeConstraints { make in
            make.top.equalTo(newTitleLabel.snp.bottom).offset(layout.current.topInset)
            make.centerX.equalTo(newTitleLabel)
            make.trailing.lessThanOrEqualToSuperview()
            make.leading.lessThanOrEqualTo(arrowImageView.snp.trailing)
        }
    }
}

extension RekeyTransitionView {
    func setOldTitleLabel(_ title: String?) {
        oldTitleLabel.text = title
    }
    
    func setOldValueLabel(_ value: String?) {
        oldValueLabel.text = value
    }
    
    func setNewTitleLabel(_ title: String?) {
        newTitleLabel.text = title
    }
    
    func setNewValueLabel(_ value: String?) {
        newValueLabel.text = value
    }
}

extension RekeyTransitionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let contentSize = CGSize(width: UIScreen.main.bounds.width - 40.0, height: 100.0)
        let arrowOffset: CGFloat = 40.0
        let titleBottomInset: CGFloat = 4.0
        let topInset: CGFloat = 8.0
        let iconSize = CGSize(width: 24.0, height: 24.0)
    }
}
