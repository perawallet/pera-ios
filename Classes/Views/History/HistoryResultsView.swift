//
//  HistoryResultsView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class HistoryResultsView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var accountSelectionView: SelectionView = {
        let accountSelectionView = SelectionView()
        accountSelectionView.containerView.backgroundColor = Colors.disabledColor
        accountSelectionView.leftExplanationLabel.text = "history-account".localized
        return accountSelectionView
    }()
    
    private(set) lazy var assetSelectionView: SelectionView = {
        let assetSelectionView = SelectionView()
        assetSelectionView.containerView.backgroundColor = Colors.disabledColor
        assetSelectionView.leftExplanationLabel.text = "history-asset".localized
        return assetSelectionView
    }()
    
    private(set) lazy var startDateDisplayView: DetailedInformationView = {
        let startDateDisplayView = DetailedInformationView()
        startDateDisplayView.backgroundColor = .clear
        startDateDisplayView.explanationLabel.text = "history-start-date".localized
        startDateDisplayView.isUserInteractionEnabled = true
        startDateDisplayView.detailLabel.font = UIFont.font(.overpass, withWeight: .semiBold(size: 14.0))
        return startDateDisplayView
    }()
    
    private(set) lazy var endDateDisplayView: DetailedInformationView = {
        let endDateDisplayView = DetailedInformationView()
        endDateDisplayView.backgroundColor = .clear
        endDateDisplayView.explanationLabel.text = "history-end-date".localized
        endDateDisplayView.isUserInteractionEnabled = true
        endDateDisplayView.detailLabel.font = UIFont.font(.overpass, withWeight: .semiBold(size: 14.0))
        return endDateDisplayView
    }()
    
    private lazy var rewardsSwitchView: RewardsSwitchView = {
        let view = RewardsSwitchView()
        view.isHidden = true
        view.toggle.isEnabled = false
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
    
    override func prepareLayout() {
        setupAccountSelectionViewLayout()
        setupAssetSelectionViewLayout()
        setupStartDateDisplayViewLayout()
        setupEndDateDisplayViewLayout()
        setupTransactionHistoryCollectionViewLayout()
    }
}

extension HistoryResultsView {
    private func setupAccountSelectionViewLayout() {
        addSubview(accountSelectionView)
        
        accountSelectionView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }
    }
    
    private func setupAssetSelectionViewLayout() {
        addSubview(assetSelectionView)
        
        assetSelectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(accountSelectionView.snp.bottom)
        }
    }
    
    private func setupStartDateDisplayViewLayout() {
        addSubview(startDateDisplayView)
        
        startDateDisplayView.snp.makeConstraints { make in
            make.top.equalTo(assetSelectionView.snp.bottom)
            make.leading.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width / 2)
        }
    }
    
    private func setupEndDateDisplayViewLayout() {
        addSubview(endDateDisplayView)
        
        endDateDisplayView.snp.makeConstraints { make in
            make.top.equalTo(assetSelectionView.snp.bottom)
            make.trailing.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width / 2)
        }
    }
    
    private func setupRewardsSwitchViewLayout() {
        addSubview(rewardsSwitchView)
        
        rewardsSwitchView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.rewardsViewInset)
            make.top.equalTo(endDateDisplayView.snp.bottom).offset(layout.current.rewardsViewInset)
        }
    }
    
    private func setupTransactionHistoryCollectionViewLayout() {
        addSubview(transactionHistoryCollectionView)
        
        transactionHistoryCollectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(endDateDisplayView.snp.bottom).offset(layout.current.collectionViewTopInset)
        }
        
        transactionHistoryCollectionView.backgroundView = contentStateView
    }
}

extension HistoryResultsView {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 35.0
        let horizontalInset: CGFloat = 25.0
        let separatorInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 1.0
        let toLabelTopInset: CGFloat = 30.0
        let labelMinimumInset: CGFloat = 5.0
        let collectionViewTopInset: CGFloat = 20.0
        let rewardsViewInset: CGFloat = 15.0
    }
}

extension HistoryResultsView {
    private enum Colors {
        static let disabledColor = rgb(0.91, 0.91, 0.92)
    }
}
