//
//  HistoryResultsView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class HistoryResultsView: BaseView {
    
    struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 35.0
        let horizontalInset: CGFloat = 25.0
        let separatorInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 1.0
        let toLabelTopInset: CGFloat = 30.0
        let labelMinimumInset: CGFloat = 5.0
        let collectionViewTopInset: CGFloat = 24.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var accountNameLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 14.0)))
            .withLine(.single)
            .withAlignment(.left)
            .withTextColor(SharedColors.black)
    }()
    
    private(set) lazy var accountAmountView: AlgosAmountView = {
        let view = AlgosAmountView()
        return view
    }()
    
    private lazy var topSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = SharedColors.softGray
        return view
    }()
    
    private(set) lazy var startDateLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 14.0)))
            .withLine(.single)
            .withAlignment(.left)
            .withTextColor(SharedColors.black)
    }()
    
    private lazy var toLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)))
            .withLine(.single)
            .withAlignment(.center)
            .withTextColor(SharedColors.softGray)
            .withText("history-result-to".localized)
    }()
    
    private(set) lazy var endDateLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 14.0)))
            .withLine(.single)
            .withAlignment(.right)
            .withTextColor(SharedColors.black)
    }()
    
    private lazy var bottomSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = SharedColors.softGray
        return view
    }()
    
    private(set) lazy var transactionHistoryCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.contentInset = .zero
        collectionView.backgroundColor = .white
        
        collectionView.register(TransactionHistoryCell.self, forCellWithReuseIdentifier: TransactionHistoryCell.reusableIdentifier)
        
        return collectionView
    }()
    
    private lazy var contentStateView = ContentStateView()

    // MARK: Setup
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupAccountNameLabelLayout()
        setupAccountAmountViewLayout()
        setupTopSeparatorViewLayout()
        setupToLabelLayout()
        setupStartDateLabelLayout()
        setupEndDateLabelLayout()
        setupBottomSeparatorViewLayout()
        setupTransactionHistoryCollectionViewLayout()
    }
    
    private func setupAccountNameLabelLayout() {
        addSubview(accountNameLabel)
        
        accountNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupAccountAmountViewLayout() {
        addSubview(accountAmountView)
        
        accountAmountView.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(accountNameLabel.snp.trailing).offset(layout.current.labelMinimumInset)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalTo(accountNameLabel)
        }
    }
    
    private func setupTopSeparatorViewLayout() {
        addSubview(topSeparatorView)
        
        topSeparatorView.snp.makeConstraints { make in
            make.top.equalTo(accountNameLabel.snp.bottom).offset(layout.current.separatorInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.separatorInset)
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
    
    private func setupToLabelLayout() {
        addSubview(toLabel)
        
        toLabel.snp.makeConstraints { make in
            make.top.equalTo(topSeparatorView.snp.bottom).offset(layout.current.toLabelTopInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupStartDateLabelLayout() {
        addSubview(startDateLabel)
        
        startDateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalTo(toLabel)
            make.trailing.lessThanOrEqualTo(toLabel.snp.leading).inset(-layout.current.labelMinimumInset)
        }
    }
    
    private func setupEndDateLabelLayout() {
        addSubview(endDateLabel)
        
        endDateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalTo(toLabel)
            make.leading.greaterThanOrEqualTo(toLabel.snp.leading).offset(layout.current.labelMinimumInset)
        }
    }
    
    private func setupBottomSeparatorViewLayout() {
        addSubview(bottomSeparatorView)
        
        bottomSeparatorView.snp.makeConstraints { make in
            make.top.equalTo(toLabel.snp.bottom).offset(layout.current.separatorInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.separatorInset)
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
    
    private func setupTransactionHistoryCollectionViewLayout() {
        addSubview(transactionHistoryCollectionView)
        
        transactionHistoryCollectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(bottomSeparatorView.snp.bottom).offset(layout.current.collectionViewTopInset)
        }
        
        transactionHistoryCollectionView.backgroundView = contentStateView
    }
}
