//
//  ReceiveAlgosViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SnapKit

class RequestTransactionPreviewViewController: BaseViewController {
    
    private lazy var requestTransactionPreviewView = RequestTransactionPreviewView()
    
    private var keyboard = Keyboard()
    private var contentViewBottomConstraint: Constraint?
    private var amount: Double = 0.00
    private let account: Account
    private var assetDetail: AssetDetail?
    private let isAlgoTransaction: Bool
    
    init(account: Account, assetDetail: AssetDetail?, configuration: ViewControllerConfiguration, isAlgoTransaction: Bool = false) {
        self.account = account
        self.assetDetail = assetDetail
        self.isAlgoTransaction = isAlgoTransaction
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestTransactionPreviewView.amountInputView.beginEditing()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        if isAlgoTransaction {
            configureViewForAlgos()
        } else {
            configureViewForAssets()
        }
    }
    
    override func setListeners() {
        super.setListeners()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceive(keyboardWillShow:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceive(keyboardWillHide:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func linkInteractors() {
        requestTransactionPreviewView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupRequestTransactionPreviewViewLayout()
    }
}

extension RequestTransactionPreviewViewController {
    private func setupRequestTransactionPreviewViewLayout() {
        view.addSubview(requestTransactionPreviewView)
        
        requestTransactionPreviewView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            contentViewBottomConstraint = make.bottom.equalToSuperview().inset(view.safeAreaBottom).constraint
        }
    }
}

extension RequestTransactionPreviewViewController {
    private func configureViewForAlgos() {
        title = "request-algos-title".localized
        requestTransactionPreviewView.transactionParticipantView.accountSelectionView.detailLabel.text = account.name
        requestTransactionPreviewView.transactionParticipantView.assetSelectionView.detailLabel.text = "asset-algos-title".localized
        requestTransactionPreviewView.transactionParticipantView.assetSelectionView.amountView.amountLabel.textColor =
            SharedColors.turquois
        requestTransactionPreviewView.transactionParticipantView.assetSelectionView.amountView.algoIconImageView.tintColor =
            SharedColors.turquois
    }
    
    private func configureViewForAssets() {
        requestTransactionPreviewView.transactionParticipantView.accountSelectionView.amountView.amountLabel.textColor = SharedColors.black
        requestTransactionPreviewView.transactionParticipantView.accountSelectionView.amountView.algoIconImageView.isHidden = true
        requestTransactionPreviewView.transactionParticipantView.accountSelectionView.detailLabel.text = account.name
        requestTransactionPreviewView.amountInputView.algosImageView.isHidden = true
        title = "request-asset-title".localized
        
        guard let assetDetail = assetDetail,
            let assetName = assetDetail.assetName,
            let assetCode = assetDetail.unitName else {
            return
        }
        
        let nameText = assetName.attributed()
        let codeText = "(\(assetCode))".attributed([.textColor(SharedColors.purple)])
        requestTransactionPreviewView.transactionParticipantView.assetSelectionView.detailLabel.attributedText = nameText + codeText
    }
}

extension RequestTransactionPreviewViewController {
    private func displayPreview() {
        if let algosAmountText = requestTransactionPreviewView.amountInputView.inputTextField.text,
            let doubleValue = algosAmountText.doubleForSendSeparator {
            amount = doubleValue
        }
        
        if !isTransactionValid() {
            displaySimpleAlertWith(title: "send-algos-alert-title".localized, message: "send-algos-alert-message".localized)
        }
        
        view.endEditing(true)
        
        let transaction = TransactionPreviewDraft(
            fromAccount: account,
            amount: amount,
            identifier: nil,
            fee: nil,
            isAlgoTransaction: isAlgoTransaction,
            assetDetail: assetDetail
        )
        open(.requestTransaction(transaction: transaction), by: .push)
    }
    
    private func isTransactionValid() -> Bool {
        if amount > 0.0 {
            return true
        }
        
        return false
    }
}

extension RequestTransactionPreviewViewController {
    @objc
    fileprivate func didReceive(keyboardWillShow notification: Notification) {
        if !UIApplication.shared.isActive {
            return
        }
        
        let kbHeight = notification.keyboardHeight ?? view.safeAreaBottom
        
        keyboard.height = kbHeight
        
        let duration = notification.keyboardAnimationDuration
        let curve = notification.keyboardAnimationCurve
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(curve.rawValue >> 16))
        
        contentViewBottomConstraint?.update(inset: kbHeight)
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: [curveAnimationOption],
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
    @objc
    fileprivate func didReceive(keyboardWillHide notification: Notification) {
        if !UIApplication.shared.isActive {
            return
        }
        
        let duration = notification.keyboardAnimationDuration
        let curve = notification.keyboardAnimationCurve
        let curveAnimationOption = UIView.AnimationOptions(rawValue: UInt(curve.rawValue >> 16))
        
        contentViewBottomConstraint?.update(inset: view.safeAreaBottom)
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: [curveAnimationOption],
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
}

extension RequestTransactionPreviewViewController: RequestTransactionPreviewViewDelegate {
    func requestTransactionPreviewViewDidTapPreviewButton(_ requestTransactionPreviewView: RequestTransactionPreviewView) {
        displayPreview()
    }
}
