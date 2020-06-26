//
//  TransactionDetailViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class TransactionDetailViewController: BaseScrollViewController {
    
    private lazy var transactionDetailView = TransactionDetailView(transactionType: transactionType)
    
    private var transaction: Transaction
    private let account: Account
    private var assetDetail: AssetDetail?
    private let transactionType: TransactionType
    private var pollingOperation: PollingOperation?
    
    private let transactionDetailTooltipStorage = TransactionDetailTooltipStorage()
    
    private let viewModel = TransactionDetailViewModel()
    
    init(
        account: Account,
        transaction: Transaction,
        transactionType: TransactionType,
        assetDetail: AssetDetail?,
        configuration: ViewControllerConfiguration
    ) {
        self.account = account
        self.transaction = transaction
        self.transactionType = transactionType
        self.assetDetail = assetDetail
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startPolling()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.presentInformationCopyTooltipIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pollingOperation?.invalidate()
    }
    
    override func linkInteractors() {
        transactionDetailView.delegate = self
    }
    
    override func setListeners() {
        super.setListeners()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didContactAdded(notification:)),
            name: .ContactAddition,
            object: nil
        )
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "transaction-detail-title".localized
        contentView.backgroundColor = SharedColors.secondaryBackground
        setSecondaryBackgroundColor()
        configureTransactionDetail()
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupTransactionDetailViewLayout()
    }
}

extension TransactionDetailViewController {
    @objc
    private func didContactAdded(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Contact],
            let contact = userInfo["contact"] else {
                return
        }
        
        transaction.contact = contact
        viewModel.setOpponent(for: transaction, with: contact.address ?? "", in: transactionDetailView)
    }
}

extension TransactionDetailViewController {
    private func startPolling() {
        pollingOperation = PollingOperation(interval: 1.0) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.fetchTransactionDetail()
        }
        
        if transaction.isPending() {
            pollingOperation?.start()
        }
    }
    
    private func fetchTransactionDetail() {
        if !transaction.isPending() {
            return
        }
        
        api?.fetchTransactionDetail(for: account, with: transaction.id) { response in
            switch response {
            case let .success(transaction):
                if !transaction.isPending() {
                    transaction.contact = self.transaction.contact
                    self.transaction = transaction
                    self.transaction.status = .completed
                    self.configureTransactionDetail()
                    self.pollingOperation?.invalidate()
                }
            case .failure:
                break
            }
        }
    }
}

extension TransactionDetailViewController {
    private func configureTransactionDetail() {
        if transactionType == .sent {
            viewModel.configureSentTransaction(transactionDetailView, with: transaction, and: assetDetail, for: account)
        } else {
            viewModel.configureReceivedTransaction(transactionDetailView, with: transaction, and: assetDetail, for: account)
        }
    }
    
    private func presentInformationCopyTooltipIfNeeded() {
        if transactionDetailTooltipStorage.isInformationCopyTooltipDisplayed() || !isViewAppeared {
            return
        }
        
        let tooltipViewController = TooltipViewController(title: "transaction-detail-copy-tooltip".localized, configuration: configuration)
        tooltipViewController.presentationController?.delegate = self
        tooltipViewController.setSourceView(transactionDetailView.opponentView.copyImageView)
        present(tooltipViewController, animated: true)
        
        transactionDetailTooltipStorage.setInformationCopyTooltipDisplayed()
    }
}

extension TransactionDetailViewController {
    private func setupTransactionDetailViewLayout() {
        contentView.addSubview(transactionDetailView)
        
        transactionDetailView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension TransactionDetailViewController: TransactionDetailViewDelegate {
    func transactionDetailViewDidTapOpponentActionButton(_ transactionDetailView: TransactionDetailView) {
        guard let opponentType = viewModel.opponentType else {
            return
        }
        
        switch opponentType {
        case let .contact(address):
            let draft = QRCreationDraft(address: address, mode: .address)
            open(.qrGenerator(title: transaction.contact?.name ?? "qr-creation-sharing-title".localized, draft: draft), by: .present)
        case let .localAccount(address):
            let draft = QRCreationDraft(address: address, mode: .address)
            open(.qrGenerator(title: "qr-creation-sharing-title".localized, draft: draft), by: .present)
        case let .address(address):
            let viewController = open(.addContact(mode: .new()), by: .push) as? AddContactViewController
            viewController?.addContactView.userInformationView.algorandAddressInputView.value = address
        }
    }
    
    func transactionDetailViewDidCopyOpponentAddress(_ transactionDetailView: TransactionDetailView) {
        guard let opponentType = viewModel.opponentType else {
            return
        }
        
        switch opponentType {
        case let .contact(address),
             let .localAccount(address),
             let .address(address):
            UIPasteboard.general.string = address
        }
        
        displaySimpleAlertWith(title: "qr-creation-copied".localized)
    }
    
    func transactionDetailViewDidCopyCloseToAddress(_ transactionDetailView: TransactionDetailView) {
        UIPasteboard.general.string = transaction.payment?.closeAddress
        displaySimpleAlertWith(title: "qr-creation-copied".localized)
    }
    
    func transactionDetailViewDidCopyTransactionID(_ transactionDetailView: TransactionDetailView) {
        UIPasteboard.general.string = transaction.id
        displaySimpleAlertWith(title: "transaction-detail-id-copied".localized)
    }
    
    func transactionDetailViewDidCopyTransactionNote(_ transactionDetailView: TransactionDetailView) {
        UIPasteboard.general.string = transaction.noteRepresentation()
        displaySimpleAlertWith(title: "transaction-detail-note-copied".localized)
    }
}

extension TransactionDetailViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        return .none
    }
}

enum TransactionType {
    case sent
    case received
}

private struct TransactionDetailTooltipStorage: Storable {
    typealias Object = Any
    
    private let informationCopyTooltipKey = "com.algorand.algorand.transaction.detail.information.copy.tooltip"
    
    func setInformationCopyTooltipDisplayed() {
        save(true, for: informationCopyTooltipKey, to: .defaults)
    }
    
    func isInformationCopyTooltipDisplayed() -> Bool {
        return bool(with: informationCopyTooltipKey, to: .defaults)
    }
}
