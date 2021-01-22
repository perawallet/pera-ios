//
//  LedgerDeviceView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerDeviceView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: LedgerDeviceViewDelegate?
    
    private lazy var backgroundImageView = UIImageView(image: img("bg-ledger-device"))
    
    private lazy var deviceImageView = UIImageView(image: img("img-ledger-small"))
    
    private lazy var deviceNameLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withAlignment(.left)
            .withTextColor(Colors.Text.primary)
    }()
    
    private lazy var connectButton: UIButton = {
        UIButton(type: .custom)
            .withTitle("ledger-device-list-connect".localized)
            .withTitleColor(Colors.ButtonText.actionButton)
            .withFont(UIFont.font(withWeight: .semiBold(size: 14.0)))
    }()
    
    override func setListeners() {
        connectButton.addTarget(self, action: #selector(notifyDelegateToConnectLedgerDevice), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupBackgroundImageViewLayout()
        setupDeviceImageViewLayout()
        setupConnectButtonLayout()
        setupDeviceNameLabelLayout()
    }
}

extension LedgerDeviceView {
    @objc
    private func notifyDelegateToConnectLedgerDevice() {
        delegate?.ledgerDeviceViewDidTapConnectButton(self)
    }
}

extension LedgerDeviceView {
    private func setupBackgroundImageViewLayout() {
        addSubview(backgroundImageView)
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupDeviceImageViewLayout() {
        addSubview(deviceImageView)
        
        deviceImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupConnectButtonLayout() {
        addSubview(connectButton)
        
        connectButton.setContentHuggingPriority(.required, for: .horizontal)
        connectButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        connectButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupDeviceNameLabelLayout() {
        addSubview(deviceNameLabel)
        
        deviceNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(deviceImageView.snp.trailing).offset(layout.current.nameHorizontalOffset)
            make.trailing.lessThanOrEqualTo(connectButton.snp.leading).offset(-layout.current.nameHorizontalOffset)
            make.centerY.equalTo(deviceImageView)
        }
    }
}

extension LedgerDeviceView {
    func bind(_ viewModel: LedgerDeviceListViewModel) {
        deviceNameLabel.text = viewModel.ledgerName
    }
}

extension LedgerDeviceView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let nameHorizontalOffset: CGFloat = 12.0
    }
}

protocol LedgerDeviceViewDelegate: class {
    func ledgerDeviceViewDidTapConnectButton(_ ledgerDeviceView: LedgerDeviceView)
}
