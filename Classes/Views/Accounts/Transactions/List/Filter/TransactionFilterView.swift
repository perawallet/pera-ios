//
//  TransactionFilterView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.06.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class TransactionFilterView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: TransactionFilterViewDelegate?
    
    private(set) lazy var filterOptionsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 4.0
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(
            TransactionFilterOptionCell.self,
            forCellWithReuseIdentifier: TransactionFilterOptionCell.reusableIdentifier
        )
        return collectionView
    }()
    
    private lazy var closeButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("bg-light-gray-button"))
            .withTitle("title-close".localized)
            .withTitleColor(Colors.Text.primary)
            .withAlignment(.center)
            .withFont(UIFont.font(withWeight: .semiBold(size: 14.0)))
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func setListeners() {
        closeButton.addTarget(self, action: #selector(notifyDelegateToDismissView), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupCloseButtonLayout()
        setupFilterOptionsCollectionViewLayout()
    }
}

extension TransactionFilterView {
    @objc
    private func notifyDelegateToDismissView() {
        delegate?.transactionFilterViewDidDismissView(self)
    }
}

extension TransactionFilterView {
    private func setupCloseButtonLayout() {
        addSubview(closeButton)
        
        closeButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset + safeAreaBottom)
        }
    }
    
    private func setupFilterOptionsCollectionViewLayout() {
        addSubview(filterOptionsCollectionView)
        
        filterOptionsCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(closeButton.snp.top).offset(-layout.current.bottomInset)
        }
    }
}

extension TransactionFilterView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let bottomInset: CGFloat = 16.0
        let topInset: CGFloat = 8.0
        let horizontalInset: CGFloat = 20.0
    }
}

protocol TransactionFilterViewDelegate: class {
    func transactionFilterViewDidDismissView(_ transactionFilterView: TransactionFilterView)
}
