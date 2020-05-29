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
    
    private var keyboard = Keyboard()
    private var contentViewBottomConstraint: Constraint?
    private(set) var amount = 0.00
    var account: Account
    private var isReceiverEditable: Bool
    
    var filterOption: SelectAssetViewController.FilterOption {
        return .none
    }
    
    init(account: Account, isReceiverEditable: Bool, configuration: ViewControllerConfiguration) {
        self.account = account
        self.isReceiverEditable = isReceiverEditable
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [weak self] in
            self?.closeScreen(by: .dismiss, animated: true)
        }
        
        if isReceiverEditable {
            leftBarButtonItems = [closeBarButtonItem]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTestNetBanner()
    }
    
    override func setListeners() {
        super.setListeners()
        setKeyboardListeners()
    }
    
    func openRequestScreen() { }
    
    func configure(forSelected account: Account, with assetDetail: AssetDetail?) { }
}

extension RequestTransactionPreviewViewController {
    func prepareLayout(of requestTransactionPreviewView: RequestTransactionPreviewView) {
        view.addSubview(requestTransactionPreviewView)
        
        requestTransactionPreviewView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            contentViewBottomConstraint = make.bottom.equalToSuperview().inset(view.safeAreaBottom).constraint
        }
    }
}

extension RequestTransactionPreviewViewController {
    private func setKeyboardListeners() {
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
    
    private func displayPreview(from requestTransactionPreviewView: RequestTransactionPreviewView) {
        if let algosAmountText = requestTransactionPreviewView.amountInputView.inputTextField.text,
            let doubleValue = algosAmountText.doubleForSendSeparator(with: algosFraction) {
            amount = doubleValue
        }
        
        if !isRequestValid() {
            displaySimpleAlertWith(title: "send-algos-alert-title".localized, message: "send-algos-alert-message".localized)
        }
        
        view.endEditing(true)
        openRequestScreen()
    }
    
    private func isRequestValid() -> Bool {
        return amount > 0.0
    }
}

extension RequestTransactionPreviewViewController {
    @objc
    private func didReceive(keyboardWillShow notification: Notification) {
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
    private func didReceive(keyboardWillHide notification: Notification) {
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
        displayPreview(from: requestTransactionPreviewView)
    }
    
    func requestTransactionPreviewDidTapAssetSelectionView(_ requestTransactionPreviewView: RequestTransactionPreviewView) {
        let controller = open(
            .selectAsset(
                transactionAction: .request,
                filterOption: filterOption
            ),
            by: .present
        ) as? SelectAssetViewController
        controller?.delegate = self
    }
    
    func requestTransactionPreviewDidTapRemoveButton(_ requestTransactionPreviewView: RequestTransactionPreviewView) {
        requestTransactionPreviewView.setAssetSelectionHidden(!isReceiverEditable)
    }
}

extension RequestTransactionPreviewViewController: SelectAssetViewControllerDelegate {
    func selectAssetViewController(
        _ selectAssetViewController: SelectAssetViewController,
        didSelectAlgosIn account: Account,
        forAction transactionAction: TransactionAction
    ) {
        configure(forSelected: account, with: nil)
    }
    
    func selectAssetViewController(
        _ selectAssetViewController: SelectAssetViewController,
        didSelect assetDetail: AssetDetail,
        in account: Account,
        forAction transactionAction: TransactionAction
    ) {
        configure(forSelected: account, with: assetDetail)
    }
}
