//
//  SendTransactionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import Magpie
import SVProgressHUD

protocol SendTransactionViewControllerDelegate: class {
    func sendTransactionViewController(_ viewController: SendTransactionViewController, didCompleteTransactionFor asset: Int64?)
}

class SendTransactionViewController: BaseViewController {
    
    weak var delegate: SendTransactionViewControllerDelegate?
    
    private(set) lazy var sendTransactionView = SendTransactionView()
    
    private let assetReceiverState: AssetReceiverState
    private(set) var isSenderEditable: Bool
    private(set) var transactionController: TransactionController
    var fee: Int64?
    
    private let viewModel = SendTransactionViewModel()
    
    var transactionData: Data?
    
    init(
        assetReceiverState: AssetReceiverState,
        transactionController: TransactionController,
        isSenderEditable: Bool,
        configuration: ViewControllerConfiguration
    ) {
        self.assetReceiverState = assetReceiverState
        self.transactionController = transactionController
        self.isSenderEditable = isSenderEditable
        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTestNetBanner()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        viewModel.configure(sendTransactionView, with: assetReceiverState, and: fee)
    }
    
    override func linkInteractors() {
        sendTransactionView.transactionDelegate = self
        transactionController.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupSendTransactionViewLayout()
    }
    
    func completeTransaction(with id: TransactionID) { }
}

extension SendTransactionViewController {
    private func setupSendTransactionViewLayout() {
        view.addSubview(sendTransactionView)
        
        sendTransactionView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.safeEqualToBottom(of: self)
        }
    }
}

extension SendTransactionViewController: SendTransactionViewDelegate {
    func sendTransactionViewDidTapSendButton(_ sendTransactionView: SendTransactionView) {
        SVProgressHUD.show(withStatus: "title-loading".localized)
        transactionController.uploadTransaction()
    }
}

extension SendTransactionViewController: TransactionControllerDelegate {
    func transactionController(_ transactionController: TransactionController, didCompletedTransaction id: TransactionID) {
        SVProgressHUD.dismiss()
        completeTransaction(with: id)
        
        if isSenderEditable {
            dismissScreen()
            return
        }
        
        navigateBack()
    }
    
    private func navigateBack() {
        guard let navigationController = self.navigationController else {
            return
        }
        
        var viewControllers = navigationController.viewControllers
        viewControllers.removeLast(2)
        self.navigationController?.setViewControllers(viewControllers, animated: false)
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: Error) {
        SVProgressHUD.dismiss()
        switch error {
        case .networkUnavailable:
            displaySimpleAlertWith(title: "title-error".localized, message: "title-internet-connection".localized)
        default:
            displaySimpleAlertWith(title: "title-error".localized, message: error.localizedDescription)
        }
    }
}
