//
//  TransactionErrorView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 6.07.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class TransactionErrorView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: TransactionErrorViewDelegate?
    
    private lazy var imageView = UIImageView()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTextColor(SharedColors.primaryText)
    }()
    
    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(SharedColors.secondaryText)
            .withLine(.contained)
    }()
    
    private lazy var tryAgainButton: AlignedButton = {
        let positions: AlignedButton.StylePositionAdjustment = (image: CGPoint(x: 24.0, y: 0.0), title: CGPoint(x: 0.0, y: 0.0))
        let button = AlignedButton(style: .imageLeftTitleCentered(positions))
        button.setBackgroundImage(img("bg-try-again"), for: .normal)
        button.setImage(img("icon-reload"), for: .normal)
        button.setTitle("transaction-filter-try-again".localized, for: .normal)
        button.setTitleColor(SharedColors.primaryText, for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 16.0))
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func setListeners() {
        tryAgainButton.addTarget(self, action: #selector(notifyDelegateToTryAgain), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupImageViewLayout()
        setupTitleLabelLayout()
        setupSubtitleLabelLayout()
        setupTryAgainButtonLayout()
    }
}

extension TransactionErrorView {
    @objc
    private func notifyDelegateToTryAgain() {
        delegate?.transactionErrorViewDidTryAgain(self)
    }
}

extension TransactionErrorView {
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(layout.current.imageSize)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(layout.current.titleTopInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.lessThanOrEqualToSuperview().inset(layout.current.titleHorizontalInset)
        }
    }
    
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.subtitleTopInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.lessThanOrEqualToSuperview().inset(layout.current.subtitleHorizontalInset)
        }
    }
    
    private func setupTryAgainButtonLayout() {
        addSubview(tryAgainButton)
        
        tryAgainButton.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(layout.current.buttonTopInset)
            make.centerX.equalToSuperview()
            make.size.equalTo(layout.current.buttonSize)
        }
    }
}

extension TransactionErrorView {
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setSubtitle(_ subtitle: String) {
        subtitleLabel.text = subtitle
    }
}

extension TransactionErrorView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 100.0
        let imageSize = CGSize(width: 48.0, height: 48.0)
        let titleTopInset: CGFloat = 16.0
        let titleHorizontalInset: CGFloat = 20.0
        let subtitleHorizontalInset: CGFloat = 40.0
        let subtitleTopInset: CGFloat = 8.0
        let buttonTopInset: CGFloat = 24.0
        let buttonSize = CGSize(width: 153.0, height: 44.0)
    }
}

protocol TransactionErrorViewDelegate: class {
    func transactionErrorViewDidTryAgain(_ transactionErrorView: TransactionErrorView)
}
