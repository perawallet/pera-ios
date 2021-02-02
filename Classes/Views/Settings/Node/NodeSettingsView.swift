//
//  NodeSettingsView.swift

import UIKit

class NodeSettingsView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var headerView = NodeSettingsHeaderView()
    
    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 12.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = Colors.Background.primary
        collectionView.contentInset = .zero
        collectionView.register(NodeSelectionCell.self, forCellWithReuseIdentifier: NodeSelectionCell.reusableIdentifier)
        return collectionView
    }()
    
    override func prepareLayout() {
        setupHeaderViewLayout()
        setupCollectionViewLayout()
    }
}

extension NodeSettingsView {
    private func setupHeaderViewLayout() {
        addSubview(headerView)
        
        headerView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.headerHeight)
        }
    }
    
    private func setupCollectionViewLayout() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
}

extension NodeSettingsView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let headerHeight: CGFloat = 210.0
    }
}
