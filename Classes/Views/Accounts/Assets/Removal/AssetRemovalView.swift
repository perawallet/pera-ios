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
        view.backgroundColor = .white
        view.layer.cornerRadius = 4.0
        view.layer.borderWidth = 1.0
        view.layer.borderColor = Colors.borderColor.cgColor
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 11.0)))
            .withAttributedText("asset-remove-title".localized.attributed([.letterSpacing(1.10), .textColor(SharedColors.orange)]))
    }()
    
    private lazy var subtitleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .regular(size: 13.0)))
            .withTextColor(SharedColors.darkGray)
            .withLine(.contained)
            .withAlignment(.left)
            .withText("asset-remove-subtitle".localized)
    }()
    
    private(set) lazy var assetsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.contentInset = .zero
        
        collectionView.register(AssetActionableCell.self, forCellWithReuseIdentifier: AssetActionableCell.reusableIdentifier)
        collectionView.register(
            AccountHeaderSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: AccountHeaderSupplementaryView.reusableIdentifier
        )
        
        return collectionView
    }()
    
    override func prepareLayout() {
        setupTopContainerViewLayout()
        setupTitleLabelLayout()
        setupSubtitleLabelLayout()
        setupAssetsCollectionViewLayout()
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

    private func setupTitleLabelLayout() {
        topContainerView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(layout.current.labelHorizontalInset)
        }
    }
    
    private func setupSubtitleLabelLayout() {
        topContainerView.addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.subtitleTopInset)
            make.trailing.equalToSuperview().inset(layout.current.labelHorizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.subtitleBottomInset)
            
        }
    }

    private func setupAssetsCollectionViewLayout() {
        addSubview(assetsCollectionView)
        
        assetsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(topContainerView.snp.bottom).offset(layout.current.collectionViewTopInset)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension AssetRemovalView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 10.0
        let containerTopInset: CGFloat = 6.0
        let labelHorizontalInset: CGFloat = 15.0
        let subtitleTopInset: CGFloat = 11.0
        let subtitleBottomInset: CGFloat = 17.0
        let collectionViewTopInset: CGFloat = -12.0
    }
    
    private enum Colors {
        static let borderColor = rgb(0.91, 0.91, 0.92)
    }
}
