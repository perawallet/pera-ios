//
//  RequestTransactionPreviewView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class RequestTransactionPreviewView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: RequestTransactionPreviewViewDelegate?
    
    private var inputFieldFraction: Int
    
    private lazy var assetSelectionView: SelectionView = {
        let view = SelectionView()
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private(set) lazy var transactionAccountInformationView = TransactionAccountInformationView()
    
    private(set) lazy var amountInputView = AssetInputView(inputFieldFraction: inputFieldFraction)
    
    private(set) lazy var previewButton = MainButton(title: "title-preview".localized)
    
    init(inputFieldFraction: Int) {
        self.inputFieldFraction = inputFieldFraction
        super.init(frame: .zero)
    }
    
    override func setListeners() {
        transactionAccountInformationView.delegate = self
    }
    
    override func linkInteractors() {
        previewButton.addTarget(self, action: #selector(notifyDelegateToPreviewButtonTapped), for: .touchUpInside)
        assetSelectionView.addTarget(self, action: #selector(notifyDelegateToSelectAsset), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupAssetSelectionViewLayout()
        setupTransactionAccountInformationViewLayout()
        setupAmountInputViewLayout()
        setupPreviewButtonLayout()
    }
}

extension RequestTransactionPreviewView {
    private func setupAssetSelectionViewLayout() {
        addSubview(assetSelectionView)
        
        assetSelectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupTransactionAccountInformationViewLayout() {
        addSubview(transactionAccountInformationView)
        
        transactionAccountInformationView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupAmountInputViewLayout() {
        addSubview(amountInputView)
        
        amountInputView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.amountFieldTopInset)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupPreviewButtonLayout() {
        addSubview(previewButton)
        
        previewButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(amountInputView.snp.bottom).offset(layout.current.buttonVerticalInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.buttonVerticalInset)
        }
    }
}

extension RequestTransactionPreviewView {
    @objc
    private func notifyDelegateToPreviewButtonTapped() {
        delegate?.requestTransactionPreviewViewDidTapPreviewButton(self)
    }
    
    @objc
    private func notifyDelegateToSelectAsset() {
        delegate?.requestTransactionPreviewDidTapAssetSelectionView(self)
    }
}

extension RequestTransactionPreviewView: TransactionAccountInformationViewDelegate {
    func transactionAccountInformationViewDidTapRemoveButton(_ transactionAccountInformationView: TransactionAccountInformationView) {
        delegate?.requestTransactionPreviewDidTapRemoveButton(self)
    }
}

extension RequestTransactionPreviewView {
    func setAssetSelectionHidden(_ hidden: Bool) {
        transactionAccountInformationView.isHidden = !hidden
        assetSelectionView.isHidden = hidden
        assetSelectionView.isUserInteractionEnabled = !hidden
        
        amountInputView.snp.updateConstraints { make in
            if hidden {
                make.top.equalToSuperview().inset(layout.current.amountFieldTopInset)
            } else {
                make.top.equalToSuperview().inset(layout.current.amountFieldTopInsetToAssetSelection)
            }
        }
    }
}

extension RequestTransactionPreviewView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 12.0
        let amountTopInset: CGFloat = 20.0
        let buttonVerticalInset: CGFloat = 28.0
        let horizontalInset: CGFloat = 20.0
        let amountFieldTopInset: CGFloat = 154.0
        let amountFieldTopInsetToAssetSelection: CGFloat = 108.0
    }
}

protocol RequestTransactionPreviewViewDelegate: class {
    func requestTransactionPreviewViewDidTapPreviewButton(_ requestTransactionPreviewView: RequestTransactionPreviewView)
    func requestTransactionPreviewDidTapAssetSelectionView(_ requestTransactionPreviewView: RequestTransactionPreviewView)
    func requestTransactionPreviewDidTapRemoveButton(_ requestTransactionPreviewView: RequestTransactionPreviewView)
}
