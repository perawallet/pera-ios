//
//  SendAlgosViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class SendAlgosViewController: BaseViewController {
    
    // MARK: Variables
    
    private lazy var accountListModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .backgroundTouch
        )
    )
    
    // MARK: Components
    
    private lazy var sendAlgosView: SendAlgosView = {
        let view = SendAlgosView()
        return view
    }()
    
    // MARK: Initialization
    
    override init(configuration: ViewControllerConfiguration) {
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "send-algos-title".localized
    }
    
    override func linkInteractors() {
        sendAlgosView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupSendAlgosViewLayout()
    }
    
    private func setupSendAlgosViewLayout() {
        view.addSubview(sendAlgosView)
        
        sendAlgosView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.safeEqualToBottom(of: self)
        }
    }
    
    // MARK: Navigation
    
    private func presentAccountList() {
        let accountListViewController = open(
            .accountList(mode: .onlyList),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: accountListModalPresenter
            )
        ) as? AccountListViewController
        
        accountListViewController?.delegate = self
    }
    
    private func displayQRScanner() {
        let qrScannerViewController = open(.qrScanner, by: .push) as? QRScannerViewController
        
        qrScannerViewController?.delegate = self
    }
    
    private func displayContactList() {
        let contactsViewController = open(.contacts, by: .push) as? ContactsViewController
        
        contactsViewController?.delegate = self
    }
    
    private func displayTransactionPreview() {
        // TODO: Handle fee amount.
        
        open(.sendAlgosPreview, by: .push)
    }
}

// MARK: SendAlgosViewDelegate

extension SendAlgosViewController: SendAlgosViewDelegate {
    
    func sendAlgosViewDidTapAccoutSelectionView(_ sendAlgosView: SendAlgosView) {
        presentAccountList()
    }
    
    func sendAlgosViewDidTapPreviewButton(_ sendAlgosView: SendAlgosView) {
        displayTransactionPreview()
    }
    
    func sendAlgosViewDidTapContactsButton(_ sendAlgosView: SendAlgosView) {
        displayContactList()
    }
    
    func sendAlgosViewDidTapQRButton(_ sendAlgosView: SendAlgosView) {
        displayQRScanner()
    }
}

// MARK: AccountListViewControllerDelegate

extension SendAlgosViewController: AccountListViewControllerDelegate {
    
    func accountListViewControllerDidTapAddButton(_ viewController: AccountListViewController) {
    }
    
    func accountListViewController(_ viewController: AccountListViewController, didSelectAccount account: Account) {
        
    }
}

// MARK: AccountListViewControllerDelegate

extension SendAlgosViewController: ContactsViewControllerDelegate {
    
    func contactsViewController(_ contactsViewController: ContactsViewController, didSelect contact: Contact) {
        
    }
}

// MARK: QRScannerViewControllerDelegate

extension SendAlgosViewController: QRScannerViewControllerDelegate {
    
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText) {
        
    }
    
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError) {
        
    }
}
