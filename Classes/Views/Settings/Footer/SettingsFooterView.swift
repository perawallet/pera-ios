//
//  SettingsFooterView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class SettingsFooterView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: SettingsFooterViewDelegate?
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .custom)
            .withTitle("settings-logout-title".localized)
            .withAlignment(.center)
            .withTitleColor(SharedColors.gray700)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withBackgroundColor(SharedColors.secondaryBackground)
        button.layer.cornerRadius = 22.0
        return button
    }()
    
    private lazy var versionLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.center)
            .withLine(.single)
            .withTextColor(SharedColors.gray500)
            .withFont(UIFont.font(withWeight: .regular(size: 12.0)))
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            label.text = "settings-app-version".localized(params: version)
        }
        return label
    }()
    
    override func configureAppearance() {
        super.configureAppearance()
        logoutButton.applySmallShadow()
    }
    
    override func setListeners() {
        logoutButton.addTarget(self, action: #selector(notifyDelegateToLogout), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupLogoutButtonLayout()
        setupVersionLabelLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        logoutButton.updateShadowLayoutWhenViewDidLayoutSubviews(cornerRadius: 22.0)
    }
}

extension SettingsFooterView {
    @objc
    private func notifyDelegateToLogout() {
        delegate?.settingsFooterViewDidTapLogoutButton(self)
    }
}

extension SettingsFooterView {
    private func setupLogoutButtonLayout() {
        addSubview(logoutButton)
        
        logoutButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.buttonTopInset)
            make.size.equalTo(layout.current.buttonSize)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupVersionLabelLayout() {
        addSubview(versionLabel)
        
        versionLabel.snp.makeConstraints { make in
            make.top.equalTo(logoutButton.snp.bottom).offset(layout.current.labelTopInset)
            make.centerX.equalToSuperview()
        }
    }
}

extension SettingsFooterView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let buttonTopInset: CGFloat = 28.0
        let buttonSize = CGSize(width: 146.0, height: 44.0)
        let labelTopInset: CGFloat = 12.0
    }
}

protocol SettingsFooterViewDelegate: class {
    func settingsFooterViewDidTapLogoutButton(_ settingsFooterView: SettingsFooterView)
}
