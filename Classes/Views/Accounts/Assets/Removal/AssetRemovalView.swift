//
//  AssetRemovalView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AssetRemovalView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.Background.secondary
        view.layer.cornerRadius = 12.0
        return view
    }()
    
    private lazy var infoImageView = UIImageView(image: img("icon-info-green"))
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withTextColor(Colors.Text.primary)
            .withText("asset-remove-title".localized)
    }()
    
    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.tertiary)
            .withLine(.contained)
            .withAlignment(.left)
            .withText("asset-remove-subtitle".localized)
    }()
    
    private(set) lazy var assetsCollectionView: AssetsCollectionView = {
        let collectionView = AssetsCollectionView(containsPendingAssets: false)
        collectionView.backgroundColor = Colors.Background.primary
        collectionView.contentInset = .zero
        collectionView.layer.cornerRadius = 12.0
        collectionView.register(
            AccountHeaderSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: AccountHeaderSupplementaryView.reusableIdentifier
        )
        return collectionView
    }()
    
    override func configureAppearance() {
        super.configureAppearance()
        if !isDarkModeDisplay {
            topContainerView.applyMediumShadow()
        }
    }
    
    override func prepareLayout() {
        setupTopContainerViewLayout()
        setupInfoImageViewLayout()
        setupTitleLabelLayout()
        setupSubtitleLabelLayout()
        setupAssetsCollectionViewLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isDarkModeDisplay {
            topContainerView.updateShadowLayoutWhenViewDidLayoutSubviews()
        }
    }
}

extension AssetRemovalView {
    private func setupTopContainerViewLayout() {
        addSubview(topContainerView)
        
        topContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.containerTopInset)
        }
    }

    private func setupInfoImageViewLayout() {
        topContainerView.addSubview(infoImageView)
        
        infoImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(layout.current.defaultInset)
            make.size.equalTo(layout.current.imageSize)
        }
    }
    
    private func setupTitleLabelLayout() {
        topContainerView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.defaultInset)
            make.leading.equalTo(infoImageView.snp.trailing).offset(layout.current.titleHorizontalInset)
        }
    }
    
    private func setupSubtitleLabelLayout() {
        topContainerView.addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.subtitleTopInset)
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.bottom.equalToSuperview().inset(layout.current.defaultInset)
            
        }
    }

    private func setupAssetsCollectionViewLayout() {
        addSubview(assetsCollectionView)
        
        assetsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(topContainerView.snp.bottom).offset(layout.current.collectionViewVerticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.collectionViewVerticalInset)
        }
    }
}

extension AssetRemovalView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
        let defaultInset: CGFloat = 16.0
        let titleHorizontalInset: CGFloat = 12.0
        let containerTopInset: CGFloat = 10.0
        let subtitleTopInset: CGFloat = 8.0
        let collectionViewVerticalInset: CGFloat = 20.0
    }
}
