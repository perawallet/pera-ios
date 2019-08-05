//
//  SettingsView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class SettingsView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let collectionViewHeight: CGFloat = Environment.current.isAuctionsEnabled ? 400.0 : 320.0
        let versionLabelOffset: CGFloat = 20.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.contentInset = .zero
        collectionView.keyboardDismissMode = .onDrag
        
        collectionView.register(SettingsDetailCell.self, forCellWithReuseIdentifier: SettingsDetailCell.reusableIdentifier)
        collectionView.register(SettingsInfoCell.self, forCellWithReuseIdentifier: SettingsInfoCell.reusableIdentifier)
        collectionView.register(ToggleCell.self, forCellWithReuseIdentifier: ToggleCell.reusableIdentifier)
        collectionView.register(CoinlistCell.self, forCellWithReuseIdentifier: CoinlistCell.reusableIdentifier)
        
        return collectionView
    }()
    
    private lazy var versionLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.single)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 14.0)))
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupCollectionViewLayout()
        setupVersionLabelLayout()
    }
    
    private func setupCollectionViewLayout() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.collectionViewHeight)
        }
    }
    
    private func setupVersionLabelLayout() {
        addSubview(versionLabel)
        
        versionLabel.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(layout.current.versionLabelOffset)
            make.centerX.equalToSuperview()
        }
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "Version \(version)"
        }
    }
}
