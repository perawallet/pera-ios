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
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 12.0)))
            .withAlignment(.left)
            .withTextColor(.black)
    }()
    
    private lazy var connectButton: UIButton = {
        UIButton(type: .custom)
            .withTitle("ledger-device-list-connect".localized)
            .withTitleColor(SharedColors.purple)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 12.0)))
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
            make.leading.equalToSuperview().inset(layout.current.imageInset)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupConnectButtonLayout() {
        addSubview(connectButton)
        
        connectButton.setContentHuggingPriority(.required, for: .horizontal)
        connectButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        connectButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().inset(layout.current.buttonTrailingInset)
        }
    }
    
    private func setupDeviceNameLabelLayout() {
        addSubview(deviceNameLabel)
        
        deviceNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(deviceImageView.snp.trailing).offset(layout.current.nameLeadingOffset)
            make.trailing.lessThanOrEqualTo(connectButton.snp.leading).offset(layout.current.nameTrailingOffset)
            make.centerY.equalTo(deviceImageView)
        }
    }
}

extension LedgerDeviceView {
    func setDeviceName(_ deviceName: String) {
        deviceNameLabel.text = deviceName
    }
}

extension LedgerDeviceView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let imageInset: CGFloat = 16.0
        let buttonTrailingInset: CGFloat = 15.0
        let nameLeadingOffset: CGFloat = 10.0
        let nameTrailingOffset: CGFloat = -20.0
    }
}

protocol LedgerDeviceViewDelegate: class {
    func ledgerDeviceViewDidTapConnectButton(_ ledgerDeviceView: LedgerDeviceView)
}
