//
//  SendAlgosView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol SendAlgosViewDelegate: class {
    
    func sendAlgosViewDidTapAccountSelectionView(_ sendAlgosView: SendAlgosView)
    func sendAlgosViewDidTapPreviewButton(_ sendAlgosView: SendAlgosView)
    func sendAlgosViewDidTapContactsButton(_ sendAlgosView: SendAlgosView)
    func sendAlgosViewDidTapQRButton(_ sendAlgosView: SendAlgosView)
}

class SendAlgosView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 15.0 * verticalScale
        let horizontalInset: CGFloat = 25.0
        let accountsViewInset: CGFloat = 20.0
        let bottomInset: CGFloat = 18.0
        let buttonMinimumInset: CGFloat = 18.0 * verticalScale
    }
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: SendAlgosViewDelegate?
    
    // MARK: Components
    
    private(set) lazy var algosInputView: AlgosInputView = {
        let view = AlgosInputView()
        return view
    }()
    
    private(set) lazy var accountSelectionView: SingleLineInputField = {
        let selectAccountView = SingleLineInputField(displaysRightInputAccessoryButton: true)
        selectAccountView.explanationLabel.text = "send-algos-from".localized
        selectAccountView.inputTextField.text = "send-algos-select".localized
        selectAccountView.rightInputAccessoryButton.setImage(img("icon-arrow"), for: .normal)
        selectAccountView.inputTextField.isEnabled = false
        selectAccountView.inputTextField.textColor = SharedColors.black
        selectAccountView.inputTextField.tintColor = SharedColors.black
        return selectAccountView
    }()
    
    private(set) lazy var transactionReceiverView = TransactionReceiverView()
    
    private(set) lazy var previewButton: UIButton = {
        UIButton(type: .custom)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 14.0)))
            .withBackgroundImage(img("bg-dark-gray-button-big"))
            .withTitle("title-preview".localized)
            .withTitleColor(SharedColors.black)
    }()
    
    // MARK: Setup
    
    override func setListeners() {
        transactionReceiverView.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(notifyDelegateToAccountSelectionViewTapped))
        
        accountSelectionView.isUserInteractionEnabled = true
        accountSelectionView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func linkInteractors() {
        previewButton.addTarget(self, action: #selector(notifyDelegateToPreviewButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupAlgosInputViewLayout()
        setupAccountSelectionViewLayout()
        setupTransactionReceiverViewLayout()
        setupPreviewButtonLayout()
    }
    
    private func setupAlgosInputViewLayout() {
        addSubview(algosInputView)
        
        algosInputView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.height.equalTo(88.0)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupAccountSelectionViewLayout() {
        addSubview(accountSelectionView)
        
        accountSelectionView.snp.makeConstraints { make in
            make.top.equalTo(algosInputView.snp.bottom).offset(layout.current.accountsViewInset)
            make.height.equalTo(68.0)
            make.leading.trailing.equalToSuperview()
        }
        
        accountSelectionView.rightInputAccessoryButton.snp.updateConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupTransactionReceiverViewLayout() {
        addSubview(transactionReceiverView)
        
        transactionReceiverView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(accountSelectionView.snp.bottom)
        }
    }
    
    private func setupPreviewButtonLayout() {
        addSubview(previewButton)
        
        previewButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.greaterThanOrEqualTo(transactionReceiverView.snp.bottom).offset(layout.current.buttonMinimumInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToPreviewButtonTapped() {
        delegate?.sendAlgosViewDidTapPreviewButton(self)
    }
    
    @objc
    private func notifyDelegateToAccountSelectionViewTapped() {
        delegate?.sendAlgosViewDidTapAccountSelectionView(self)
    }
}

// MARK: TransactionReceiverViewDelegate

extension SendAlgosView: TransactionReceiverViewDelegate {
    
    func transactionReceiverViewDidTapContactsButton(_ transactionReceiverView: TransactionReceiverView) {
        delegate?.sendAlgosViewDidTapContactsButton(self)
    }
    
    func transactionReceiverViewDidTapQRButton(_ transactionReceiverView: TransactionReceiverView) {
        delegate?.sendAlgosViewDidTapQRButton(self)
    }
}
