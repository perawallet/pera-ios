//
//  NodeSettingsView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 10.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol NodeSettingsViewDelegate: class {
    
}

class NodeSettingsView: BaseView {
    
    struct LayoutConstants: AdaptiveLayoutConstants {
        static let headerHeight: CGFloat = 270.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var headerView: NodeSettingsHeaderView = {
        let view = NodeSettingsHeaderView()
        return view
    }()
    
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
        
        collectionView.register(SettingsToggleCell.self, forCellWithReuseIdentifier: SettingsToggleCell.reusableIdentifier)
        
        return collectionView
    }()
    
    private lazy var contentStateView = ContentStateView()
    
    weak var delegate: NodeSettingsViewDelegate?
    
    // MARK: Setup
    
    override func linkInteractors() {
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupHeaderViewLayout()
        setupCollectionViewLayout()
        setupContentStateView()
    }
    
    private func setupHeaderViewLayout() {
        addSubview(headerView)
        
        headerView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(LayoutConstants.headerHeight)
        }
    }
    
    private func setupCollectionViewLayout() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func setupContentStateView() {
        collectionView.backgroundView = contentStateView
    }
}
