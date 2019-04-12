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
        static let headerHeight: CGFloat = 276.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var accountNameLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0)))
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
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0)))
            .withLine(.single)
            .withAlignment(.left)
            .withTextColor(SharedColors.black)
    }()
    
    private lazy var toLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0)))
            .withLine(.single)
            .withAlignment(.center)
            .withTextColor(SharedColors.softGray)
            .withText("history-result-to".localized)
    }()
    
    private(set) lazy var endDateLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0)))
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
        setupStartDateLabelLayout()
        setupToLabelLayout()
        setupEndDateLabelLayout()
        setupBottomSeparatorViewLayout()
        setupTransactionHistoryCollectionViewLayout()
    }
    
    private func setupAccountNameLabelLayout() {
        addSubview(accountNameLabel)
        
        accountNameLabel.snp.makeConstraints { make in
            
        }
    }
    
    private func setupAccountAmountViewLayout() {
        addSubview(accountAmountView)
        
        accountAmountView.snp.makeConstraints { make in
            
        }
    }
    
    private func setupTopSeparatorViewLayout() {
        addSubview(topSeparatorView)
        
        topSeparatorView.snp.makeConstraints { make in
            
        }
    }
    
    private func setupStartDateLabelLayout() {
        addSubview(startDateLabel)
        
        startDateLabel.snp.makeConstraints { make in
            
        }
    }
    
    private func setupToLabelLayout() {
        addSubview(toLabel)
        
        toLabel.snp.makeConstraints { make in
            
        }
    }
    
    private func setupEndDateLabelLayout() {
        addSubview(endDateLabel)
        
        endDateLabel.snp.makeConstraints { make in
            
        }
    }
    
    private func setupBottomSeparatorViewLayout() {
        addSubview(bottomSeparatorView)
        
        bottomSeparatorView.snp.makeConstraints { make in
            
        }
    }
    
    private func setupTransactionHistoryCollectionViewLayout() {
        addSubview(transactionHistoryCollectionView)
        
        transactionHistoryCollectionView.snp.makeConstraints { make in
            
        }
    }
}
