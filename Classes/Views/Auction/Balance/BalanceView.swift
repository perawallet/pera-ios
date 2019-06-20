//
//  BalanceView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol BalanceViewDelegate: class {
    
    func balanceViewDidTapWithdrawButton(_ balanceView: BalanceView)
    func balanceViewDidTapDepositButton(_ balanceView: BalanceView)
}

class BalanceView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 25.0
        let chartHeight: CGFloat = 114.0
        let explanationTopInset: CGFloat = 10.0
        let topInset: CGFloat = 18.0
        let viewWidth: CGFloat = UIScreen.main.bounds.width / 2
    }
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: BalanceViewDelegate?
    
    // MARK: Components
    
    // amouunt label
    
    // available title label
    
    private(set) lazy var withdrawButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(SharedColors.purple)
            .withTitle("auction-enter-title".localized)
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)))
            .withBackgroundImage(img("bg-button-auction-enter"))
    }()
    
    private(set) lazy var depositButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(SharedColors.purple)
            .withTitle("auction-enter-title".localized)
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)))
            .withBackgroundImage(img("bg-button-auction-enter"))
    }()
    
    private(set) lazy var transactionsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.contentInset = .zero
        
        collectionView.register(
            PendingCoinlistTransactionCell.self,
            forCellWithReuseIdentifier: PendingCoinlistTransactionCell.reusableIdentifier
        )
        collectionView.register(
            PastCoinlistTransactionCell.self,
            forCellWithReuseIdentifier: PastCoinlistTransactionCell.reusableIdentifier
        )
        
        return collectionView
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func setListeners() {
        withdrawButton.addTarget(self, action: #selector(notifyDelegateToWithdrawButtonTapped), for: .touchUpInside)
        depositButton.addTarget(self, action: #selector(notifyDelegateToDepositButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToWithdrawButtonTapped() {
        delegate?.balanceViewDidTapWithdrawButton(self)
    }
    
    @objc
    private func notifyDelegateToDepositButtonTapped() {
        delegate?.balanceViewDidTapDepositButton(self)
    }
}
