//
//  LedgerApprovalView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 5.03.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerApprovalView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: LedgerApprovalViewDelegate?
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 16.0)))
            .withAlignment(.center)
            .withTextColor(SharedColors.black)
    }()
    
    private(set) lazy var bluetoothImageView = BluetoothLoadingView()
    
    private lazy var ledgerImageView = UIImageView(image: img("img-ledger-small"))
    
    private lazy var deviceImageView = UIImageView(image: img("img-pixel-device"))
    
    private lazy var detailLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 14.0)))
            .withAlignment(.center)
            .withTextColor(SharedColors.black)
    }()
    
    private lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withTitle("title-cancel".localized)
            .withTitleColor(SharedColors.darkGray)
            .withAlignment(.center)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)))
    }()
    
    override func configureAppearance() {
        backgroundColor = .white
        layer.cornerRadius = 10.0
    }
    
    override func setListeners() {
        cancelButton.addTarget(self, action: #selector(notifyDelegateToCancel), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupTitleLabelLayout()
        setupBluetoothImageViewLayout()
        setupDeviceImageViewLayout()
        setupLedgerImageViewLayout()
        setupDetailLabelLayout()
        setupCancelButtonLayout()
    }
}

extension LedgerApprovalView {
    @objc
    private func notifyDelegateToCancel() {
        delegate?.ledgerApprovalViewDidTapCancelButton(self)
    }
}

extension LedgerApprovalView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
            
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.titleVerticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.titleHorizontalInset)
        }
    }
    
    private func setupBluetoothImageViewLayout() {
        addSubview(bluetoothImageView)
            
        bluetoothImageView.snp.makeConstraints { make in
            make.centerX.equalTo(titleLabel)
            make.size.equalTo(layout.current.bluetoothImageSize)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.bluetoothTopInset)
        }
    }
    
    private func setupDeviceImageViewLayout() {
        addSubview(deviceImageView)
            
        deviceImageView.snp.makeConstraints { make in
            make.leading.equalTo(bluetoothImageView.snp.trailing).offset(layout.current.deviceImageLeadingInset)
            make.centerY.equalTo(bluetoothImageView)
        }
    }

    private func setupLedgerImageViewLayout() {
        addSubview(ledgerImageView)
            
        ledgerImageView.snp.makeConstraints { make in
            make.centerY.equalTo(bluetoothImageView)
            make.trailing.equalTo(bluetoothImageView.snp.leading).offset(layout.current.imageTrailingOffset)
            make.size.equalTo(layout.current.ledgerImageSize)
        }
    }
        
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
            
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(deviceImageView.snp.bottom).offset(layout.current.detailLabelTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
        
    private func setupCancelButtonLayout() {
        addSubview(cancelButton)
            
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(layout.current.buttonVerticalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(layout.current.buttonVerticalInset)
        }
    }
}

extension LedgerApprovalView {
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setDetail(_ detail: String) {
        detailLabel.text = detail
    }
}

extension LedgerApprovalView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleVerticalInset: CGFloat = 30.0
        let titleHorizontalInset: CGFloat = 25.0
        let deviceImageLeadingInset: CGFloat = 5.0
        let bluetoothTopInset: CGFloat = 75.0
        let deviceImageTopInset: CGFloat = 35.0
        let buttonVerticalInset: CGFloat = 20.0
        let imageTrailingOffset: CGFloat = -5.0
        let horizontalInset: CGFloat = 30.0
        let detailLabelTopInset: CGFloat = 40.0
        let ledgerImageSize = CGSize(width: 27.0, height: 24.0)
        let bluetoothImageSize = CGSize(width: 100.0, height: 100.0)
    }
}

protocol LedgerApprovalViewDelegate: class {
    func ledgerApprovalViewDidTapCancelButton(_ ledgerApprovalView: LedgerApprovalView)
}
