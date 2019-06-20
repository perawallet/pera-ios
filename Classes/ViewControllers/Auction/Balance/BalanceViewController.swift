//
//  BalanceViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class BalanceViewController: BaseViewController {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 20.0 * verticalScale
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var balanceView: BalanceView = {
        let view = BalanceView()
        return view
    }()
    
    // MARK: Setup

    override func configureAppearance() {
        super.configureAppearance()
        
        navigationItem.title = "balance-title".localized
    }
    
    override func linkInteractors() {
        balanceView.delegate = self
        balanceView.transactionsCollectionView.delegate = self
        balanceView.transactionsCollectionView.dataSource = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupBalanceViewLayout()
    }
    
    private func setupBalanceViewLayout() {
        view.addSubview(balanceView)
        
        balanceView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: UICollectionViewDataSource

extension BalanceViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension BalanceViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return .zero
    }

}

// MARK: BalanceViewDelegate

extension BalanceViewController: BalanceViewDelegate {
    
    func balanceViewDidTapWithdrawButton(_ balanceView: BalanceView) {
        
    }
    
    func balanceViewDidTapDepositButton(_ balanceView: BalanceView) {
        open(.deposit, by: .push)
    }
}
