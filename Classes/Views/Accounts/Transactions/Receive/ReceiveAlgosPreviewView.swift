//
//  ReceiveAlgosPreviewView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol ReceiveAlgosPreviewViewDelegate: class {
    
    func receiveAlgosPreviewViewDidTapShareButton(_ receiveAlgosPreviewView: ReceiveAlgosPreviewView)
}

class ReceiveAlgosPreviewView: ReceiveAlgosView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 45.0 * verticalScale
        let verticalInset: CGFloat = 20.0 * verticalScale
        let algosInputViewInset: CGFloat = 30.0 * verticalScale
    }
    
    private let layout = Layout<LayoutConstants>()
    
    weak var previewViewDelegate: ReceiveAlgosPreviewViewDelegate?
    
    // MARK: Components
    
    private let address: String
    
    private(set) lazy var qrView: QRView = {
        let qrText = QRText(mode: .algosReceive, text: address)
        return QRView(qrText: qrText)
    }()
    
    private(set) lazy var shareButton = MainButton(title: "title-share-big".localized)
    
    init(address: String) {
        self.address = address
        
        super.init(frame: .zero)
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        algosInputView.inputTextField.isEnabled = false
        accountSelectionView.isUserInteractionEnabled = false
    }
    
    override func setListeners() {
        shareButton.addTarget(self, action: #selector(notifyDelegateToShareButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupQRViewLayout()
        updateAlgosInputViewLayout()
        setupShareButtonLayout()
    }
    
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
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToShareButtonTapped() {
        previewViewDelegate?.receiveAlgosPreviewViewDidTapShareButton(self)
    }
}
