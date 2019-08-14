//
//  AuctionTemporaryView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 4.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AuctionTemporaryViewDelegate: class {
    
    func auctionTemporaryViewDidTapGoToAuctionButton(_ auctionTemporaryView: AuctionTemporaryView)
}

class AuctionTemporaryView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleTopInset: CGFloat = 38.0 * verticalScale
        let containerTopInset: CGFloat = 80.0 * verticalScale
        let containerHorizontalInset: CGFloat = 35.0
        let horizontalInset: CGFloat = 19.0 * verticalScale
        let imageTopInset: CGFloat = 16.0 * verticalScale
        let imageHeight: CGFloat = 110.0 * verticalScale
        let bottomContainerTopInset: CGFloat = 34.0 * verticalScale
        let bottomContainerHeight: CGFloat = 41.0 * verticalScale
        let buttonBottomInset: CGFloat = 30.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AuctionTemporaryViewDelegate?
    
    var status: AuctionStatus? = nil {
        didSet {
            if oldValue == status {
                return
            }
            
            configureViewForStatus()
        }
    }
    
    // MARK: Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 10.0
        return view
    }()
    
    private lazy var auctionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.cornerRadius = 6.0
        imageView.layer.borderWidth = 1.0
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 15.0 * verticalScale)))
            .withTextColor(.clear)
            .withLine(.contained)
            .withAlignment(.center)
            .withText("auction-temp-title".localized)
    }()
    
    private lazy var bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.layer.cornerRadius = 10.0
        return view
    }()
    
    private lazy var bottomTitleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 14.0 * verticalScale)))
            .withTextColor(.white)
            .withLine(.single)
            .withAlignment(.center)
    }()
    
    private lazy var goToAuctionButton: MainButton = {
        let button = MainButton(title: "auction-go-auctions".localized)
        return button
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func linkInteractors() {
        goToAuctionButton.addTarget(self, action: #selector(notifyDelegateToGoToAuctionButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupContainerViewLayout()
        setupAuctionImageViewLayout()
        setupTitleLabelLayout()
        setupBottomContainerViewLayout()
        setupBottomTitleLabelLayout()
        setupGoToAuctionButtonLayout()
    }
    
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.containerHorizontalInset)
            make.top.equalToSuperview().inset(layout.current.containerTopInset)
        }
    }
    
    private func setupAuctionImageViewLayout() {
        containerView.addSubview(auctionImageView)
        
        auctionImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.imageTopInset)
            make.height.equalTo(layout.current.imageHeight)
        }
    }
    
    private func setupTitleLabelLayout() {
        containerView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(auctionImageView.snp.bottom).offset(layout.current.titleTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupBottomContainerViewLayout() {
        containerView.addSubview(bottomContainerView)
        
        bottomContainerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(layout.current.bottomContainerHeight)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.bottomContainerTopInset)
        }
    }
    
    private func setupBottomTitleLabelLayout() {
        bottomContainerView.addSubview(bottomTitleLabel)
        
        bottomTitleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupGoToAuctionButtonLayout() {
        addSubview(goToAuctionButton)
        
        goToAuctionButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(layout.current.buttonBottomInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToGoToAuctionButtonTapped() {
        delegate?.auctionTemporaryViewDidTapGoToAuctionButton(self)
    }
    
    // MARK: Configuration
    
    private func configureViewForStatus() {
        guard let status = status else {
            return
        }
        
        containerView.layer.borderWidth = 1.0
        titleLabel.textColor = SharedColors.darkGray
        auctionImageView.image = img("img-auction-temp")
        
        switch status {
        case .announced:
            containerView.layer.borderColor = SharedColors.darkGray.cgColor
            containerView.backgroundColor = SharedColors.warmWhite
            auctionImageView.layer.borderColor = SharedColors.darkGray.cgColor
            bottomContainerView.backgroundColor = SharedColors.darkGray
            bottomTitleLabel.text = "auction-scheduled-title".localized
        case .running:
            containerView.layer.borderColor = SharedColors.purple.cgColor
            containerView.backgroundColor = SharedColors.purple.withAlphaComponent(0.1)
            auctionImageView.layer.borderColor = SharedColors.purple.cgColor
            bottomContainerView.backgroundColor = SharedColors.purple
            bottomTitleLabel.text = "auction-live-title".localized
        case .closed:
            containerView.layer.borderColor = SharedColors.orange.cgColor
            containerView.backgroundColor = SharedColors.orange.withAlphaComponent(0.1)
            auctionImageView.layer.borderColor = SharedColors.orange.cgColor
            bottomContainerView.backgroundColor = SharedColors.orange
            bottomTitleLabel.text = "auction-closed-title".localized
        case .settled:
            containerView.layer.borderColor = SharedColors.orange.cgColor
            containerView.backgroundColor = SharedColors.orange.withAlphaComponent(0.1)
            auctionImageView.layer.borderColor = SharedColors.orange.cgColor
            bottomContainerView.backgroundColor = SharedColors.orange
            bottomTitleLabel.text = "auction-settled-title".localized
        }
    }
}
