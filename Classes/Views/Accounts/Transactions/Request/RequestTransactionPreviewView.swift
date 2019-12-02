//
//  RequestTransactionPreviewView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol RequestTransactionPreviewViewDelegate: class {
    func requestTransactionPreviewViewDidTapAccountSelectionView(_ requestTransactionPreviewView: RequestTransactionPreviewView)
    func requestTransactionPreviewViewDidTapPreviewButton(_ requestTransactionPreviewView: RequestTransactionPreviewView)
}

class RequestTransactionPreviewView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: RequestTransactionPreviewViewDelegate?
    
    private(set) lazy var algosInputView = AlgosInputView()
    
    private(set) lazy var accountSelectionView: AccountSelectionView = {
        let accountSelectionView = AccountSelectionView()
        accountSelectionView.explanationLabel.text = "send-algos-to".localized
        return accountSelectionView
    }()
    
    private(set) lazy var previewButton = MainButton(title: "title-preview".localized)
    
    override func setListeners() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(notifyDelegateToAccountSelectionViewTapped))
        accountSelectionView.isUserInteractionEnabled = true
        accountSelectionView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func linkInteractors() {
        previewButton.addTarget(self, action: #selector(notifyDelegateToPreviewButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupAlgosInputViewLayout()
        setupAccountSelectionViewLayout()
        setupPreviewButtonLayout()
    }
}

extension RequestTransactionPreviewView {
    private func setupAlgosInputViewLayout() {
        addSubview(algosInputView)
        
        algosInputView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupAccountSelectionViewLayout() {
        addSubview(accountSelectionView)
        
        accountSelectionView.snp.makeConstraints { make in
            make.top.equalTo(algosInputView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupPreviewButtonLayout() {
        addSubview(previewButton)
        
        previewButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.top.greaterThanOrEqualTo(accountSelectionView.snp.bottom).offset(layout.current.buttonMinimumInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
        }
    }
}

extension RequestTransactionPreviewView {
    @objc
    private func notifyDelegateToPreviewButtonTapped() {
        delegate?.requestTransactionPreviewViewDidTapPreviewButton(self)
    }
    
    @objc
    private func notifyDelegateToAccountSelectionViewTapped() {
        delegate?.requestTransactionPreviewViewDidTapAccountSelectionView(self)
    }
}

extension RequestTransactionPreviewView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 20.0
        let horizontalInset: CGFloat = 25.0
        let bottomInset: CGFloat = 18.0
        let buttonInset: CGFloat = 15.0
        let buttonMinimumInset: CGFloat = 18.0
        let buttonHorizontalInset: CGFloat = MainButton.Constants.horizontalInset
    }
}
