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
    
    private var user: AuctionUser
    
    private let viewModel = BalanceViewModel()
    
    // MARK: Components
    
    private lazy var balanceView: BalanceView = {
        let view = BalanceView()
        return view
    }()
    
    // MARK: Initialization
    
    init(user: AuctionUser, configuration: ViewControllerConfiguration) {
        self.user = user
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
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
    
    // MARK: API
    
    private func fetchAuctionUser() {
        api?.fetchAuctionUser { response in
            switch response {
            case let .success(receivedUser):
                self.user = receivedUser
            case .failure:
                break
            }
        }
    }
    
    private func fetchPastTransactions() {
        api?.fetchCoinlistTransactions { response in
            switch response {
            case let .success(receivedTransactions):
                print(receivedTransactions)
            case .failure:
                break
            }
        }
    }
    
    private func fetchUserInstructions() {
        fetchUSDWireInstructions()
        fetchBTCDepositInstructions()
        fetchETHDepositInstructions()
    }
    
    private func fetchUSDWireInstructions() {
        api?.fetchUSDDepositInformation { response in
            switch response {
            case let .success(receivedInstruction):
                print(receivedInstruction)
            case .failure:
                break
            }
        }
    }
    
    private func fetchBTCDepositInstructions() {
        api?.fetchBlockchainDepositInformation(for: .btc) { response in
            switch response {
            case let .success(receivedInstruction):
                print(receivedInstruction)
            case .failure:
                break
            }
        }
    }
    
    private func fetchETHDepositInstructions() {
        api?.fetchBlockchainDepositInformation(for: .eth) { response in
            switch response {
            case let .success(receivedInstruction):
                print(receivedInstruction)
            case .failure:
                break
            }
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
        open(.deposit(user: user), by: .push)
    }
}
