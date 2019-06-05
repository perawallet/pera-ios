//
//  AlertView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AlertView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 31.0
        let titleHorizontalInset: CGFloat = 25.0
        let backgroundImageTopInset: CGFloat = 49.0
        let backgroundImageSize = CGSize(width: 100.0, height: 100.0)
        let explanationLabelInset: CGFloat = 42.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 20.0)))
            .withLine(.contained)
            .withAlignment(.center)
            .withTextColor(SharedColors.black)
    }()
    
    private lazy var iconBackgroundImageView = UIImageView(image: img("bg-alert-icon"))
    
    private(set) lazy var imageView = UIImageView()
    
    private(set) lazy var explanationLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 13.0)))
            .withLine(.contained)
            .withAlignment(.center)
            .withTextColor(SharedColors.black)
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = SharedColors.warmWhite
        layer.cornerRadius = 10.0
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupIconBackgroundImageViewLayout()
        setupImageViewLayout()
        setupExplanationLabelLayout()
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.defaultInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.titleHorizontalInset)
        }
    }
    
    private func setupIconBackgroundImageViewLayout() {
        addSubview(iconBackgroundImageView)
        
        iconBackgroundImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.backgroundImageTopInset)
            make.size.equalTo(layout.current.backgroundImageSize)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupImageViewLayout() {
        iconBackgroundImageView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupExplanationLabelLayout() {
        addSubview(explanationLabel)
        
        explanationLabel.snp.makeConstraints { make in
            make.top.equalTo(iconBackgroundImageView.snp.bottom).offset(layout.current.defaultInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.explanationLabelInset)
        }
    }
}
