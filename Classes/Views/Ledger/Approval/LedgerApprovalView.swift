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
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 12.0)))
            .withAlignment(.left)
            .withTextColor(.black)
    }()
    
    private lazy var bluetoothImageView = UIImageView(image: img("img-ledger-small"))
    
    private lazy var ledgerImageView = UIImageView(image: img("img-ledger-small"))
    
    private lazy var deviceImageView = UIImageView(image: img("img-ledger-small"))
    
    private lazy var detailLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 12.0)))
            .withAlignment(.left)
            .withTextColor(.black)
    }()
    
    private lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withTitle("ledger-device-list-connect".localized)
            .withTitleColor(SharedColors.purple)
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
        setupDeviceImageViewLayout()
        setupBluetoothImageViewLayout()
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
            make.top.equalToSuperview().inset(30.0)
            make.leading.trailing.equalToSuperview().inset(25.0)
        }
    }
    
    private func setupDeviceImageViewLayout() {
        addSubview(deviceImageView)
            
        deviceImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.imageInset)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupBluetoothImageViewLayout() {
        addSubview(bluetoothImageView)
            
        bluetoothImageView.snp.makeConstraints { make in
            make.centerY.equalTo(deviceImageView)
            make.trailing.equalTo(deviceImageView.snp.leading).offset(-45.0)
            make.size.equalTo(CGSize(width: 30.0, height: 30.0))
        }
    }

    private func setupLedgerImageViewLayout() {
        addSubview(ledgerImageView)
            
        ledgerImageView.snp.makeConstraints { make in
            make.centerY.equalTo(deviceImageView)
            make.trailing.equalTo(bluetoothImageView.snp.leading).offset(-45.0)
            make.size.equalTo(CGSize(width: 30.0, height: 30.0))
        }
    }
        
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
            
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(deviceImageView.snp.bottom).offset(40.0)
            make.leading.trailing.equalToSuperview().inset(30.0)
        }
    }
        
    private func setupCancelButtonLayout() {
        addSubview(cancelButton)
            
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(20.0)
            make.leading.trailing.equalToSuperview().inset(30.0)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(20.0)
        }
    }
}
extension LedgerApprovalView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let imageInset: CGFloat = 16.0
        let buttonTrailingInset: CGFloat = 15.0
        let nameLeadingOffset: CGFloat = 10.0
        let nameTrailingOffset: CGFloat = -20.0
    }
}

protocol LedgerApprovalViewDelegate: class {
    func ledgerApprovalViewDidTapCancelButton(_ ledgerApprovalView: LedgerApprovalView)
}
