//
//  AccountsHeaderView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 4.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class AccountsHeaderView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AccountsHeaderViewDelegate?
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .bold(size: 28.0)))
            .withTextColor(SharedColors.primaryText)
            .withAlignment(.left)
            .withText("accounts-title".localized)
    }()
    
    private lazy var testNetLabel: UILabel = {
        let label = UILabel()
            .withFont(UIFont.font(withWeight: .bold(size: 10.0)))
            .withTextColor(SharedColors.primaryButtonTitle)
            .withAlignment(.center)
            .withText("title-testnet".localized)
        label.backgroundColor = SharedColors.testNetBanner
        label.layer.cornerRadius = 12.0
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()
    
    private lazy var qrButton: UIButton = {
        let button = UIButton(type: .custom).withImage(img("img-accounts-scan-qr"))
        button.contentMode = .scaleToFill
        return button
    }()
    
    private lazy var addButton: UIButton = {
        UIButton(type: .custom).withImage(img("img-accounts-add"))
    }()
    
    override func configureAppearance() {
        super.configureAppearance()
        qrButton.applyShadow(Shadow(color: Colors.shadowColor, offset: CGSize(width: 0.0, height: 4.0), radius: 12.0, opacity: 1.0))
    }
    
    override func setListeners() {
        qrButton.addTarget(self, action: #selector(notifyDelegateToScanQR), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(notifyDelegateToAddAccount), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupAddButtonLayout()
        setupQRButtonLayout()
        setupTestNetLabelLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        qrButton.layer.shadowPath = UIBezierPath(roundedRect: qrButton.bounds, cornerRadius: 20.0).cgPath
    }
}

extension AccountsHeaderView {
    @objc
    private func notifyDelegateToScanQR() {
        delegate?.accountsHeaderViewDidTapQRButton(self)
    }
    
    @objc
    private func notifyDelegateToAddAccount() {
        delegate?.accountsHeaderViewDidTapAddButton(self)
    }
}

extension AccountsHeaderView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupAddButtonLayout() {
        addSubview(addButton)
        
        addButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.buttonSize)
        }
    }
    
    private func setupQRButtonLayout() {
        addSubview(qrButton)
        
        qrButton.snp.makeConstraints { make in
            make.trailing.equalTo(addButton.snp.leading).offset(layout.current.buttonOffset)
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.buttonSize)
        }
    }
    
    private func setupTestNetLabelLayout() {
        addSubview(testNetLabel)
        
        testNetLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(layout.current.labelOffset)
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(layout.current.testNetLabelSize)
        }
    }
}

extension AccountsHeaderView {
    func setTestNetLabelHidden(_ hidden: Bool) {
        testNetLabel.isHidden = hidden
    }
}

extension AccountsHeaderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let buttonOffset: CGFloat = -16.0
        let labelOffset: CGFloat = 8.0
        let verticalInset: CGFloat = 18.0
        let buttonSize = CGSize(width: 40.0, height: 40.0)
        let testNetLabelSize = CGSize(width: 63.0, height: 24.0)
    }
}

extension AccountsHeaderView {
    private enum Colors {
        static let shadowColor = rgba(0.26, 0.26, 0.31, 0.07)
    }
}

protocol AccountsHeaderViewDelegate: class {
    func accountsHeaderViewDidTapQRButton(_ accountsHeaderView: AccountsHeaderView)
    func accountsHeaderViewDidTapAddButton(_ accountsHeaderView: AccountsHeaderView)
}
