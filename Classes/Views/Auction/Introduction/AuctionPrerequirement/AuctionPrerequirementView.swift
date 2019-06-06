//
//  AuctionPrerequirementView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AuctionPrerequirementView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 34.0 * verticalScale
        let verticalInset: CGFloat = 20.0 * verticalScale
        let bottomContainerHeight: CGFloat = 40.0 * verticalScale
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var firstRequirementView: AuctionPrerequirementElementView = {
        let view = AuctionPrerequirementElementView()
        view.numberLabel.text = "1"
        view.titleLabel.text = "auction-introduction-prerequest-first".localized
        view.subtitleLabel.isHidden = true
        return view
    }()
    
    private lazy var secondRequirementView: AuctionPrerequirementElementView = {
        let view = AuctionPrerequirementElementView()
        view.numberLabel.text = "2"
        view.titleLabel.text = "auction-introduction-prerequest-second".localized
        view.subtitleLabel.text = "auction-introduction-prerequest-day".localized
        return view
    }()
    
    private lazy var thirdRequirementView: AuctionPrerequirementElementView = {
        let view = AuctionPrerequirementElementView()
        view.numberLabel.text = "3"
        view.titleLabel.text = "auction-introduction-prerequest-third".localized
        view.subtitleLabel.text = "auction-introduction-prerequest-day".localized
        return view
    }()
    
    private lazy var bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = SharedColors.softGray
        
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.layer.cornerRadius = 10.0
        return view
    }()
    
    private(set) lazy var bottomTitleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .medium(size: 12.0 * verticalScale)))
            .withTextColor(.white)
            .withLine(.single)
            .withAlignment(.center)
            .withText("auction-introduction-bottom-title".localized)
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
        
        layer.cornerRadius = 10.0
        layer.borderWidth = 1.0
        layer.borderColor = SharedColors.softGray.cgColor
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupFirstRequirementViewLayout()
        setupSecondRequirementViewLayout()
        setupThirdRequirementViewLayout()
        setupBottomContainerViewLayout()
        setupBottomTitleLabelLayout()
    }
    
    private func setupFirstRequirementViewLayout() {
        addSubview(firstRequirementView)
        
        firstRequirementView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupSecondRequirementViewLayout() {
        addSubview(secondRequirementView)
        
        secondRequirementView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(firstRequirementView.snp.bottom).offset(layout.current.verticalInset)
        }
    }
    
    private func setupThirdRequirementViewLayout() {
        addSubview(thirdRequirementView)
        
        thirdRequirementView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(secondRequirementView.snp.bottom).offset(layout.current.verticalInset)
        }
    }
    
    private func setupBottomContainerViewLayout() {
        addSubview(bottomContainerView)
        
        bottomContainerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(layout.current.bottomContainerHeight)
        }
    }
    
    private func setupBottomTitleLabelLayout() {
        bottomContainerView.addSubview(bottomTitleLabel)
        
        bottomTitleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
