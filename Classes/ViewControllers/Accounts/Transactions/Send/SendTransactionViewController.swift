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
    
    private lazy var sendTransactionView = SendTransactionView()
    
    private var algosTransaction: TransactionPreviewDraft?
    private var assetTransaction: AssetTransactionDraft?
    private let receiver: AlgosReceiverState
    private var fee: Int64?
    
    var transactionData: Data?
    
    init(
        algosTransaction: TransactionPreviewDraft?,
        assetTransaction: AssetTransactionDraft?,
        receiver: AlgosReceiverState,
        configuration: ViewControllerConfiguration
    ) {
        self.algosTransaction = algosTransaction
        self.assetTransaction = assetTransaction
        self.receiver = receiver
        super.init(configuration: configuration)

        if let algosTransaction = algosTransaction {
            fee = algosTransaction.fee
            self.transactionController?.setTransactionDraft(algosTransaction)
        }
        
        if let assetTransaction = assetTransaction {
            fee = assetTransaction.fee
            self.transactionController?.setAssetTransactionDraft(assetTransaction)
        }
        
        hidesBottomBarWhenPushed = true
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        if algosTransaction == nil {
            configureViewForAsset()
            configureReceiverView()
            return
        }
        
        configureViewForAlgos()
        configureReceiverView()
    }
    
    override func linkInteractors() {
        sendTransactionView.transactionDelegate = self
        transactionController?.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupSendTransactionViewLayout()
    }
}

extension SendTransactionViewController {
    private func setupSendTransactionViewLayout() {
        view.addSubview(sendTransactionView)
        
        sendTransactionView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.safeEqualToBottom(of: self)
        }
    }
    
    fileprivate func updateFeeLayout() {
        if var receivedFee = fee {
            if receivedFee < Transaction.Constant.minimumFee {
                receivedFee = Transaction.Constant.minimumFee
            }
            sendTransactionView.feeInformationView.algosAmountView.mode = .normal(amount: receivedFee.toAlgos)
        }
    }
}

extension SendTransactionViewController {
    func configureReceiverView() {
        sendTransactionView.transactionReceiverView.state = receiver
        sendTransactionView.transactionReceiverView.receiverContainerView.backgroundColor = rgb(0.91, 0.91, 0.92)
        sendTransactionView.transactionReceiverView.actionMode = .none
        updateFeeLayout()
    }
    
    func configureViewForAlgos() {
        title = "send-algos-title".localized
        
        guard let transaction = algosTransaction else {
            return
        }
        
        sendTransactionView.transactionParticipantView.accountSelectionView.detailLabel.text = transaction.fromAccount.name
        sendTransactionView.amountInputView.inputTextField.text = transaction.amount.toDecimalStringForLabel
        sendTransactionView.transactionParticipantView.assetSelectionView.verifiedImageView.isHidden = false
        sendTransactionView.transactionParticipantView.assetSelectionView.detailLabel.text = "asset-algos-title".localized
        sendTransactionView.transactionParticipantView.assetSelectionView.set(amount: transaction.fromAccount.amount.toAlgos)
    }
    
    func configureViewForAsset() {
        guard let transaction = assetTransaction else {
            return
        }
        
        sendTransactionView.transactionParticipantView.accountSelectionView.amountView.amountLabel.textColor = SharedColors.black
        sendTransactionView.transactionParticipantView.accountSelectionView.amountView.algoIconImageView.removeFromSuperview()
        sendTransactionView.transactionParticipantView.accountSelectionView.detailLabel.text = transaction.fromAccount.name
        sendTransactionView.amountInputView.inputTextField.text =
            transaction.amount?.toFractionStringForLabel(fraction: transaction.assetDecimalFraction)
        sendTransactionView.amountInputView.algosImageView.removeFromSuperview()
        sendTransactionView.transactionParticipantView.assetSelectionView.verifiedImageView.isHidden = !transaction.isVerified
        
        guard let assetIndex = transaction.assetIndex,
            let assetDetail = transaction.fromAccount.assetDetails.first(where: { $0.id == assetIndex }) else {
            return
        }
        
        title = "title-send-lowercased".localized + " \(assetDetail.getDisplayNames().0)"
        sendTransactionView.transactionParticipantView.assetSelectionView.detailLabel.attributedText = assetDetail.assetDisplayName()
        
        if let assetAmount = transaction.fromAccount.amount(for: assetDetail) {
            sendTransactionView.transactionParticipantView.assetSelectionView.amountView.algoIconImageView.removeFromSuperview()
            sendTransactionView.transactionParticipantView.assetSelectionView.set(
                amount: assetAmount,
                assetFraction: assetDetail.fractionDecimals
            )
        }
    }
}

extension SendTransactionViewController: SendTransactionViewDelegate {
    func sendTransactionViewDidTapSendButton(_ sendTransactionView: SendTransactionView) {
        SVProgressHUD.show(withStatus: "title-loading".localized)
        transactionController?.completeTransaction()
    }
}

extension SendTransactionViewController: TransactionControllerDelegate {
    func transactionController(_ transactionController: TransactionController, didCompletedTransaction id: TransactionID) {
        SVProgressHUD.dismiss()
        algosTransaction?.identifier = id.identifier
        assetTransaction?.identifier = id.identifier
        
        delegate?.sendTransactionViewController(self, didCompleteTransactionFor: assetTransaction?.assetIndex)
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

class SendAlgosTransactionViewController: SendTransactionViewController {
    
}

class SendAlgosTransactionViewModel {
    
}

class SendAssetTransactionViewController: SendTransactionViewController {
    
}

class SendAssetTransactionViewModel {
    
}
