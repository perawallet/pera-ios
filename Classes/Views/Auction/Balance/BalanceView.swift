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
        let balanceHeaderHeight: CGFloat = 100.0
        let horizontalInset: CGFloat = 20.0
        let buttonSpacing: CGFloat = 15.0
        let buttonContainerViewHeight: CGFloat = 78.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: BalanceViewDelegate?
    
    // MARK: Components
    
    private(set) lazy var balanceHeaderView: BalanceHeaderView = {
        let view = BalanceHeaderView()
        return view
    }()
    
    private lazy var buttonContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private(set) lazy var withdrawButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(SharedColors.darkGray)
            .withTitle("balance-button-title-withdraw".localized)
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)))
            .withBackgroundImage(img("button-bg-gray-small"))
    }()
    
    private(set) lazy var depositButton: UIButton = {
        UIButton(type: .custom)
            .withTitleColor(SharedColors.blue)
            .withTitle("balance-button-title-deposit".localized)
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)))
            .withBackgroundImage(img("button-bg-navy-small"))
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
        collectionView.register(
            BlockchainDepositInstructionCell.self,
            forCellWithReuseIdentifier: BlockchainDepositInstructionCell.reusableIdentifier
        )
        collectionView.register(
            USDWireInstructionCell.self,
            forCellWithReuseIdentifier: USDWireInstructionCell.reusableIdentifier
        )
        collectionView.register(
            DepositInstructionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: DepositInstructionHeaderView.reusableIdentifier
        )
        collectionView.register(
            DepositTransactionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: DepositTransactionHeaderView.reusableIdentifier
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
        setupBalanceHeaderViewLayout()
        setupButtonContainerViewLayout()
        setupWithdrawButtonLayout()
        setupDepositButtonLayout()
        setupTransactionsCollectionViewLayout()
    }
    
    private func setupBalanceHeaderViewLayout() {
        addSubview(balanceHeaderView)
        
        balanceHeaderView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(layout.current.balanceHeaderHeight)
        }
    }
    
    private func setupButtonContainerViewLayout() {
        addSubview(buttonContainerView)
        
        buttonContainerView.snp.makeConstraints { make in
            make.top.equalTo(balanceHeaderView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.buttonContainerViewHeight)
        }
    }
    
    private func setupWithdrawButtonLayout() {
        buttonContainerView.addSubview(withdrawButton)
        
        withdrawButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupDepositButtonLayout() {
        buttonContainerView.addSubview(depositButton)
        
        depositButton.snp.makeConstraints { make in
            make.top.equalTo(withdrawButton)
            make.width.height.equalTo(withdrawButton)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.leading.equalTo(withdrawButton.snp.trailing).offset(layout.current.buttonSpacing)
        }
    }
    
    private func setupTransactionsCollectionViewLayout() {
        addSubview(transactionsCollectionView)
        
        transactionsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(buttonContainerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
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
