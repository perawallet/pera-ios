//
//  AuctionIntroductionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AuctionIntroductionViewDelegate: class {
    
    func auctionIntroductionViewDidTapGetStartedButton(_ auctionIntroductionView: AuctionIntroductionView)
}

class AuctionIntroductionView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleTopInset: CGFloat = 76.0 * verticalScale
        let groupTopInset: CGFloat = 22.0 * verticalScale
        let groupSize: CGSize = CGSize(width: 300.0 * horizontalScale, height: 240.0 * verticalScale)
        let explanationTopInset: CGFloat = 44.0 * verticalScale
        let explanationHorizontalInset: CGFloat = 71.0
        let buttonTopInset: CGFloat = 76.0 * verticalScale
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 14.0 * verticalScale)))
            .withTextColor(SharedColors.black)
            .withLine(.single)
            .withAlignment(.center)
            .withText("auction-introduction-title".localized)
    }()
    
    private lazy var auctionPrerequirementView: AuctionPrerequirementView = {
        let view = AuctionPrerequirementView()
        return view
    }()
    
    private lazy var explanationLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 14.0 * verticalScale)))
            .withTextColor(SharedColors.darkGray)
            .withLine(.contained)
            .withAlignment(.center)
    }()
    
    private lazy var getStartedButton: MainButton = {
        let button = MainButton(title: "title-get-started".localized)
        return button
    }()
    
    weak var delegate: AuctionIntroductionViewDelegate?
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
        
        explanationLabel.attributedText = "auction-introduction-explanation".localized.attributed([.lineSpacing(1.8 * verticalScale)])
        explanationLabel.textAlignment = .center
    }
    
    override func setListeners() {
        getStartedButton.addTarget(self, action: #selector(notifyDelegateToGetStartedButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupTitleLabelLayout()
        setupActionPrerequirementViewLayout()
        setupExplanationLabelLayout()
        setupGetStartedButtonLayout()
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.titleTopInset)
        }
    }
    
    private func setupActionPrerequirementViewLayout() {
        addSubview(auctionPrerequirementView)
        
        auctionPrerequirementView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.groupTopInset)
            make.size.equalTo(layout.current.groupSize)
        }
    }
    
    private func setupExplanationLabelLayout() {
        addSubview(explanationLabel)
        
        explanationLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(auctionPrerequirementView.snp.bottom).offset(layout.current.explanationTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.explanationHorizontalInset)
        }
    }
    
    private func setupGetStartedButtonLayout() {
        addSubview(getStartedButton)
        
        getStartedButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.buttonTopInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToGetStartedButtonTapped() {
        delegate?.auctionIntroductionViewDidTapGetStartedButton(self)
    }
}
