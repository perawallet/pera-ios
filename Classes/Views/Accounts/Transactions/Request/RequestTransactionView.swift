//
//  RequestTransactionViewDelegate.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class RequestTransactionView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var transactionDelegate: RequestTransactionViewDelegate?
    
    private let address: String
    private let amount: Int64
    private let assetIndex: Int64?
    
    private lazy var containerView = UIView()
    
    private lazy var accountInformationView = TransactionAccountNameView()
    
    private lazy var assetInformationView = TransactionAssetView()
    
    private lazy var amountInformationView = TransactionAmountInformationView()
    
    private(set) lazy var qrView: QRView = {
        if let assetIndex = assetIndex {
            let qrText = QRText(mode: .assetRequest, address: address, amount: amount, asset: assetIndex)
            return QRView(qrText: qrText)
        } else {
            let qrText = QRText(mode: .algosRequest, address: address, amount: amount, asset: assetIndex)
            return QRView(qrText: qrText)
        }
    }()
    
    private lazy var shareButton: UIButton = {
        let button = MainButton(title: "title-share".localized).withImage(img("icon-share-white"))
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10.0, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5.0, bottom: 0, right: 0)
        return button
    }()
    
    init(inputFieldFraction: Int, address: String, amount: Int64, assetIndex: Int64? = nil) {
        self.address = address
        self.amount = amount
        self.assetIndex = assetIndex
        super.init(frame: .zero)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        containerView.backgroundColor = SharedColors.secondaryBackground
        containerView.layer.cornerRadius = 12.0
        containerView.applySmallShadow()
        amountInformationView.setSeparatorHidden(true)
        amountInformationView.setTitle("transaction-detail-amount".localized)
    }
    
    override func setListeners() {
        shareButton.addTarget(self, action: #selector(notifyDelegateToShareButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupContainerViewLayout()
        setupQRViewLayout()
        setupAccountInformationViewLayout()
        setupAssetInformationViewLayout()
        setupAmountInformationViewLayout()
        setupShareButtonLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.setShadowFrames()
    }
}

extension RequestTransactionView {
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupQRViewLayout() {
        containerView.addSubview(qrView)
        
        qrView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.verticalInset)
            make.centerX.equalToSuperview()
            make.height.equalTo(qrView.snp.width)
        }
    }
    
    private func setupAccountInformationViewLayout() {
        containerView.addSubview(accountInformationView)
        
        accountInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(qrView.snp.bottom).offset(layout.current.topInset)
        }
    }
    
    private func setupAssetInformationViewLayout() {
        containerView.addSubview(assetInformationView)
        
        assetInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(accountInformationView.snp.bottom)
        }
    }
    
    private func setupAmountInformationViewLayout() {
        containerView.addSubview(amountInformationView)
        
        amountInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
            make.top.equalTo(assetInformationView.snp.bottom)
        }
    }
    
    private func setupShareButtonLayout() {
        addSubview(shareButton)
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(layout.current.verticalInset)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.verticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
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
    func setAccountImage(_ image: UIImage?) {
        accountInformationView.setAccountImage(image)
    }
    
    func setAccountName(_ name: String?) {
        accountInformationView.setAccountName(name)
    }
    
    func setAmountInformationViewMode(_ mode: TransactionAmountView.Mode) {
        amountInformationView.setAmountViewMode(mode)
    }
    
    func setAssetName(for assetDetail: AssetDetail) {
        assetInformationView.setAssetName(for: assetDetail)
    }
    
    func setAssetVerified(_ hidden: Bool) {
        assetInformationView.setAssetVerified(hidden)
    }
    
    func setAssetName(_ name: String) {
        assetInformationView.setAssetName(name)
    }
    
    func setAssetCode(_ code: String) {
        assetInformationView.setAssetCode(code)
    }
    
    func setAssetId(_ id: String) {
        assetInformationView.setAssetId(id)
    }
    
    func removeAssetId() {
        assetInformationView.removeAssetId()
    }
}

extension RequestTransactionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 12.0
        let bottomInset: CGFloat = 8.0
        let verticalInset: CGFloat = 28.0
        let horizontalInset: CGFloat = 20.0
    }
}

protocol RequestTransactionViewDelegate: class {
    func requestTransactionViewDidTapShareButton(_ requestTransactionView: RequestTransactionView)
}
