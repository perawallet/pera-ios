//
//  BalanceViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SafariServices

class BalanceViewController: BaseViewController {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 20.0 * verticalScale
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private var user: AuctionUser
    
    private var pendingTransactions = [CoinlistTransaction]()
    private var pastTransactions = [CoinlistTransaction]()
    
    private var depositInstructions: [DepositInstruction]?
    
    private var usdWireDepositInformation: USDWireInstruction?
    private var btcDepositInformation: BlockchainInstruction?
    private var ethDepositInformation: BlockchainInstruction?
    
    private let viewModel = BalanceViewModel()
    
    private var pollingOperation: PollingOperation?
    private var isFinishedInitialRequests = false
    private var dispatchGroup: DispatchGroup?
    
    private var sections = [Section]()
    
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
        
        viewModel.configure(balanceView, for: user)
        
        loadData()
    }
    
    private func loadData() {
        balanceView.transactionsCollectionView.contentState = .loading
        
        dispatchGroup = DispatchGroup()
        dispatchGroup?.enter()
        
        fetchPastTransactions()
        fetchAndGroupDepositInstructions()
        
        dispatchGroup?.notify(queue: .main) {
            self.isFinishedInitialRequests = true
            
            self.balanceView.transactionsCollectionView.contentState = .none
            self.balanceView.transactionsCollectionView.reloadData()
        }
    }
    
    private func fetchAndGroupDepositInstructions() {
        if let instructions = session?.authenticatedUser?.depositInstructions {
            depositInstructions = instructions
            
            for instruction in instructions {
                dispatchGroup?.enter()
                
                switch instruction.type {
                case .usd:
                    sections.append(.usd)
                    fetchUSDWireInstructions()
                case .btc:
                    sections.append(.btc)
                    fetchBTCDepositInstructions()
                case .eth:
                    sections.append(.eth)
                    fetchETHDepositInstructions()
                }
            }
        }
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
    
    // MARK: View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startPolling()
    }
    
    private func startPolling() {
        pollingOperation = PollingOperation(interval: 30.0) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            if strongSelf.isFinishedInitialRequests {
                strongSelf.fetchAuctionUser()
                strongSelf.fetchPastTransactions()
            }
        }
        
        pollingOperation?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        pollingOperation?.invalidate()
    }
    
    // MARK: API
    
    private func fetchAuctionUser() {
        api?.fetchAuctionUser { response in
            switch response {
            case let .success(receivedUser):
                self.user = receivedUser
                
                self.viewModel.configure(self.balanceView, for: self.user)
            case .failure:
                break
            }
        }
    }
    
    private func fetchPastTransactions() {
        api?.fetchCoinlistTransactions { response in
            if !self.isFinishedInitialRequests {
                self.dispatchGroup?.leave()
            }
            
            switch response {
            case let .success(receivedTransactions):
                self.pendingTransactions = self.filter(receivedTransactions, for: .pending)
                self.pastTransactions = self.filter(receivedTransactions, for: .completed)
                
                if !self.isFinishedInitialRequests {
                    if !self.pendingTransactions.isEmpty {
                        self.sections.append(.pending)
                    }
                    
                    self.sections.append(.past)
                }
                
                var reversedTransactions: [CoinlistTransaction] = self.pastTransactions.reversed()
                
                for (index, transaction) in reversedTransactions.enumerated() {
                    if index == 0 {
                        reversedTransactions[index].balanceAfterTransaction = transaction.amount
                    } else {
                        if let type = transaction.type {
                            if type == .deposit {
                                if let amount = reversedTransactions[index].amount,
                                    let previousBalance = reversedTransactions[index - 1].balanceAfterTransaction {
                                    reversedTransactions[index].balanceAfterTransaction = amount + previousBalance
                                }
                            } else {
                                if let amount = reversedTransactions[index].amount,
                                    let previousBalance = reversedTransactions[index - 1].balanceAfterTransaction {
                                    reversedTransactions[index].balanceAfterTransaction = previousBalance - amount
                                }
                            }
                        }
                    }
                }
                
                self.pastTransactions = reversedTransactions.reversed()
                
                if self.isFinishedInitialRequests {
                    self.balanceView.transactionsCollectionView.reloadData()
                }
            case .failure:
                break
            }
        }
    }
    
    private func filter(_ transactions: [CoinlistTransaction], for status: DepositStatus) -> [CoinlistTransaction] {
        let filteredTansactions = transactions.filter { transaction -> Bool in
            if let currentTransactionStatus = transaction.status {
                return status == currentTransactionStatus
            }
            
            return false
        }
        
        return filteredTansactions
    }
    
    private func fetchUSDWireInstructions() {
        api?.fetchUSDDepositInformation { response in
            if !self.isFinishedInitialRequests {
                self.dispatchGroup?.leave()
            }
            
            switch response {
            case let .success(receivedInstruction):
                self.usdWireDepositInformation = receivedInstruction
                
                if self.isFinishedInitialRequests {
                    self.balanceView.transactionsCollectionView.reloadData()
                }
            case .failure:
                break
            }
        }
    }
    
    private func fetchBTCDepositInstructions() {
        api?.fetchBlockchainDepositInformation(for: .btc) { response in
            if !self.isFinishedInitialRequests {
                self.dispatchGroup?.leave()
            }
            
            switch response {
            case let .success(receivedInstruction):
                self.btcDepositInformation = receivedInstruction
                
                if self.isFinishedInitialRequests {
                    self.balanceView.transactionsCollectionView.reloadData()
                }
            case .failure:
                break
            }
        }
    }
    
    private func fetchETHDepositInstructions() {
        api?.fetchBlockchainDepositInformation(for: .eth) { response in
            if !self.isFinishedInitialRequests {
                self.dispatchGroup?.leave()
            }
            
            switch response {
            case let .success(receivedInstruction):
                self.ethDepositInformation = receivedInstruction
                
                if self.isFinishedInitialRequests {
                    self.balanceView.transactionsCollectionView.reloadData()
                }
            case .failure:
                break
            }
        }
    }
}

// MARK: UICollectionViewDataSource

extension BalanceViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if sections.count >= section {
            let section = sections[section]
            
            switch section {
            case .pending:
                return pendingTransactions.count
            case .past:
                if pastTransactions.isEmpty {
                    return 1
                }
                
                return pastTransactions.count
            default:
                return 1
            }
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = indexPath.section
        
        if sections.count >= section {
            let section = sections[section]
            
            switch section {
            case .pending:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PendingCoinlistTransactionCell.reusableIdentifier,
                    for: indexPath) as? PendingCoinlistTransactionCell else {
                        fatalError("Index path is out of bounds")
                }
                
                if pendingTransactions.count > indexPath.row {
                    let pendingTransaction = pendingTransactions[indexPath.row]
                    viewModel.configure(cell, with: pendingTransaction)
                }
                
                return cell
            case .past:
                if pastTransactions.isEmpty {
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: PastAuctionsEmptyCell.reusableIdentifier,
                        for: indexPath) as? PastAuctionsEmptyCell else {
                            fatalError("Index path is out of bounds")
                    }
                    
                    cell.contextView.titleLabel.text = "balance-past-transactions-empty-title".localized
                    cell.contextView.imageView.image = img("img-past-coinlist-transactions-empty")
                    
                    return cell
                }
                
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PastCoinlistTransactionCell.reusableIdentifier,
                    for: indexPath) as? PastCoinlistTransactionCell else {
                        fatalError("Index path is out of bounds")
                }
                
                if pastTransactions.count > indexPath.row {
                    let pastTransaction = pastTransactions[indexPath.row]
                    viewModel.configure(cell, with: pastTransaction)
                }
                
                return cell
            case .btc,
                 .eth:
                if let depositInstructions = depositInstructions {
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: BlockchainDepositInstructionCell.reusableIdentifier,
                        for: indexPath) as? BlockchainDepositInstructionCell else {
                            fatalError("Index path is out of bounds")
                    }
                    
                    if depositInstructions.count > indexPath.section {
                        let blockchainDepositInstruction = depositInstructions[indexPath.section]
                        
                        if blockchainDepositInstruction.type == .btc {
                            if let btcDepositInformation = btcDepositInformation {
                                viewModel.configure(cell.contextView, with: btcDepositInformation, for: blockchainDepositInstruction)
                            }
                        } else if blockchainDepositInstruction.type == .eth {
                            if let ethDepositInformation = ethDepositInformation {
                                viewModel.configure(cell.contextView, with: ethDepositInformation, for: blockchainDepositInstruction)
                            }
                        }
                    }
                    
                    return cell
                }
            case .usd:
                if let depositInstructions = depositInstructions {
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: USDWireInstructionCell.reusableIdentifier,
                        for: indexPath) as? USDWireInstructionCell else {
                            fatalError("Index path is out of bounds")
                    }
                    
                    if let information = usdWireDepositInformation {
                        if depositInstructions.count > indexPath.section {
                            let usdDepositInstruction = depositInstructions[indexPath.section]
                            viewModel.configure(cell.contextView, with: information, for: usdDepositInstruction)
                        }
                    }
                    
                    return cell
                }
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        if kind != UICollectionView.elementKindSectionHeader {
            fatalError("Unexpected element kind")
        }
        
        let section = indexPath.section
        
        if sections.count >= section {
            let section = sections[section]
            
            switch section {
            case .pending,
                 .past:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: DepositTransactionHeaderView.reusableIdentifier,
                    for: indexPath
                ) as? DepositTransactionHeaderView else {
                    fatalError("Unexpected element kind")
                }
                
                headerView.tag = indexPath.section
                viewModel.configure(headerView, for: section)

                return headerView
                
            case .usd,
                 .btc,
                 .eth:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: DepositInstructionHeaderView.reusableIdentifier,
                    for: indexPath
                ) as? DepositInstructionHeaderView else {
                        fatalError("Unexpected element kind")
                }
                
                headerView.tag = indexPath.section
                headerView.delegate = self
                viewModel.configure(headerView, for: section)
                
                return headerView
            }
        }

        return UICollectionReusableView()
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension BalanceViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let section = indexPath.section
        
        if sections.count >= section {
            let section = sections[section]
            
            switch section {
            case .pending:
                return CGSize(width: UIScreen.main.bounds.width, height: 80.0)
            case .past:
                if pastTransactions.isEmpty {
                    return CGSize(width: UIScreen.main.bounds.width, height: 300.0)
                }
                
                return CGSize(width: UIScreen.main.bounds.width, height: 80.0)
            case .btc,
                 .eth:
                return CGSize(width: UIScreen.main.bounds.width, height: 147.0)
            case .usd:
                return CGSize(width: UIScreen.main.bounds.width, height: 443.0)
            }
        }
        
        return .zero
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        
        if sections.count >= section {
            let section = sections[section]
            
            switch section {
            case .pending,
                 .past:
                return CGSize(width: UIScreen.main.bounds.width, height: 51.0)
            case .btc,
                 .eth,
                 .usd:
                return CGSize(width: UIScreen.main.bounds.width, height: 65.0)
            }
        }
        
        return .zero
    }
}

// MARK: BalanceViewDelegate

extension BalanceViewController: BalanceViewDelegate {
    
    func balanceViewDidTapWithdrawButton(_ balanceView: BalanceView) {
        let configurator = AlertViewConfigurator(
            title: "balance-button-title-withdraw".localized,
            image: img("icon-withdraw-alert"),
            explanation: "balance-withdraw-website-explanation".localized,
            actionTitle: "balance-withdraw-website-title".localized,
            actionImage: img("bg-small-blue")
        ) {
            guard let algorandWebsite = URL(string: "https://auctions.algorand.foundation") else {
                return
            }
            
            let safariViewController = SFSafariViewController(url: algorandWebsite)
            self.present(safariViewController, animated: true, completion: nil)
        }
        
        let viewController = AlertViewController(mode: .destructive, alertConfigurator: configurator, configuration: configuration)
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
        
        if let alertView = viewController.alertView as? DestructiveAlertView {
            alertView.actionButton.setTitleColor(SharedColors.blue, for: .normal)
        }

        present(viewController, animated: true, completion: nil)
    }
    
    func balanceViewDidTapDepositButton(_ balanceView: BalanceView) {
        let controller = open(.deposit(user: user), by: .push) as? DepositViewController
        controller?.btcDepositInformation = btcDepositInformation
        controller?.ethDepositInformation = ethDepositInformation
        controller?.delegate = self
    }
}

// MARK: DepositViewControllerDelegate

extension BalanceViewController: DepositViewControllerDelegate {
    
    func depositViewController(_ depositViewController: DepositViewController, didComplete instruction: DepositInstruction) {
        if depositInstructions == nil {
            depositInstructions = [instruction]
        } else {
            depositInstructions?.insert(instruction, at: 0)
        }
        
        switch instruction.type {
        case .usd:
            sections.insert(.usd, at: 0)
            
            if usdWireDepositInformation == nil {
                fetchUSDWireInstructions()
            } else {
                balanceView.transactionsCollectionView.reloadData()
            }
        case .btc:
            sections.insert(.btc, at: 0)
            
            if btcDepositInformation == nil {
                fetchBTCDepositInstructions()
            } else {
                balanceView.transactionsCollectionView.reloadData()
            }
        case .eth:
            sections.insert(.eth, at: 0)
            
            if ethDepositInformation == nil {
                fetchETHDepositInstructions()
            } else {
                balanceView.transactionsCollectionView.reloadData()
            }
        }
        
    }
}

// MARK: DepositInstructionHeaderViewDelegate

extension BalanceViewController: DepositInstructionHeaderViewDelegate {
    
    func depositInstructionHeaderViewDidTapRemoveButton(_ depositInstructionHeaderView: DepositInstructionHeaderView) {
        if sections.count > depositInstructionHeaderView.tag {
            sections.remove(at: depositInstructionHeaderView.tag)
        }
        
        session?.authenticatedUser?.removeInstruction(at: depositInstructionHeaderView.tag)
        
        if let count = depositInstructions?.count,
            count > depositInstructionHeaderView.tag {
            depositInstructions?.remove(at: depositInstructionHeaderView.tag)
        }
        
        balanceView.transactionsCollectionView.reloadData()
    }
}

extension BalanceViewController {
    
    enum Section {
        case usd
        case btc
        case eth
        case pending
        case past
    }
}
