//
//  AuctionEmptyView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AuctionEmptyViewDelegate: class {
    
    func auctionEmptyViewDidTapGetStartedButton(_ auctionEmptyView: AuctionEmptyView)
}

class AuctionEmptyView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let imageTopInset: CGFloat = 80.0 * verticalScale
        let imageSize: CGSize = CGSize(width: 300.0 * horizontalScale, height: 270.0 * verticalScale)
        let titleTopInset: CGFloat = 52.0 * verticalScale
        let titleHorizontalInset: CGFloat = 36.0
        let subtitleTopInset: CGFloat = 19.0 * verticalScale
        let subtitleHorizontalInset: CGFloat = 28.0
        let buttonTopInset: CGFloat = 26.0 * verticalScale
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var emptyStateImageView = UIImageView(image: img("img-auction-empty"))
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 20.0 * verticalScale)))
            .withTextColor(SharedColors.black)
            .withLine(.single)
            .withAlignment(.center)
    }()
    
    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 14.0 * verticalScale)))
            .withTextColor(SharedColors.darkGray)
            .withLine(.contained)
            .withAlignment(.center)
    }()
    
    private lazy var getStartedButton: MainButton = {
        let button = MainButton(title: "title-get-started".localized)
        return button
    }()
    
    weak var delegate: AuctionEmptyViewDelegate?
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
        
        titleLabel.attributedText = "auction-empty-title".localized.attributed([.lineSpacing(1.2 * verticalScale)])
        titleLabel.textAlignment = .center
        subtitleLabel.attributedText = "auction-empty-subtitle".localized.attributed([.lineSpacing(1.8 * verticalScale)])
        subtitleLabel.textAlignment = .center
    }
    
    override func setListeners() {
        getStartedButton.addTarget(self, action: #selector(notifyDelegateToGetStartedButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupEmptyStateImageViewLayout()
        setupTitleLabelLayout()
        setupSubtitleLabelLayout()
        setupGetStartedButtonLayout()
    }
    
    private func setupEmptyStateImageViewLayout() {
        addSubview(emptyStateImageView)
        
        emptyStateImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.imageTopInset)
            make.size.equalTo(layout.current.imageSize)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyStateImageView.snp.bottom).offset(layout.current.titleTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.titleHorizontalInset)
        }
    }
    
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.subtitleTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.subtitleHorizontalInset)
        }
    }
    
    private func setupGetStartedButtonLayout() {
        addSubview(getStartedButton)
        
        getStartedButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(subtitleLabel.snp.bottom).offset(layout.current.buttonTopInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToGetStartedButtonTapped() {
        delegate?.auctionEmptyViewDidTapGetStartedButton(self)
    }
}
