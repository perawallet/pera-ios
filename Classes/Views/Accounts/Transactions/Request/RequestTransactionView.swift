//
//  RequestTransactionViewDelegate.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol RequestTransactionViewDelegate: class {
    func requestTransactionViewDidTapShareButton(_ requestTransactionView: RequestTransactionView)
}

class RequestTransactionView: RequestTransactionPreviewView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var transactionDelegate: RequestTransactionViewDelegate?
    
    private let address: String
    private let amount: Int64
    
    private(set) lazy var qrView: QRView = {
        let qrText = QRText(mode: .algosRequest, text: address, amount: amount)
        return QRView(qrText: qrText)
    }()
    
    private(set) lazy var shareButton = MainButton(title: "title-select".localized)
    
    init(address: String, amount: Int64) {
        self.address = address
        self.amount = amount
        
        super.init(frame: .zero)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        algosInputView.inputTextField.isEnabled = false
        accountSelectionView.isUserInteractionEnabled = false
    }
    
    override func setListeners() {
        shareButton.addTarget(self, action: #selector(notifyDelegateToShareButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupQRViewLayout()
        updateAlgosInputViewLayout()
        setupShareButtonLayout()
    }
}

extension RequestTransactionView {
    private func setupQRViewLayout() {
        addSubview(qrView)
        
        qrView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.centerX.equalToSuperview()
            make.height.equalTo(qrView.snp.width)
        }
    }
    
    private func updateAlgosInputViewLayout() {
        algosInputView.snp.remakeConstraints { make in
            make.top.equalTo(qrView.snp.bottom).offset(layout.current.algosInputViewInset)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupShareButtonLayout() {
        previewButton.removeFromSuperview()
        
        addSubview(shareButton)
        
        shareButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(algosInputView.snp.bottom).offset(layout.current.verticalInset)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
        }
    }
}

extension RequestTransactionView {
    @objc
    private func notifyDelegateToShareButtonTapped() {
        transactionDelegate?.requestTransactionViewDidTapShareButton(self)
    }
}

extension RequestTransactionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 45.0 * verticalScale
        let verticalInset: CGFloat = 20.0 * verticalScale
        let algosInputViewInset: CGFloat = 30.0 * verticalScale
        let buttonHorizontalInset: CGFloat = MainButton.Constants.horizontalInset
    }
}
