//
//  BottomInformationView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class BottomInformationView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withLine(.contained)
            .withAlignment(.center)
            .withTextColor(SharedColors.primaryText)
    }()
    
    private(set) lazy var imageView = UIImageView()
    
    private(set) lazy var explanationLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withLine(.contained)
            .withAlignment(.center)
            .withTextColor(SharedColors.primaryText)
    }()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupImageViewLayout()
        setupExplanationLabelLayout()
    }
}

extension BottomInformationView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.imageVerticalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupExplanationLabelLayout() {
        addSubview(explanationLabel)
        
        explanationLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(layout.current.explanationLabelInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension BottomInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 16.0
        let horizontalInset: CGFloat = 32.0
        let imageVerticalInset: CGFloat = 28.0
        let explanationLabelInset: CGFloat = 20.0
    }
}
