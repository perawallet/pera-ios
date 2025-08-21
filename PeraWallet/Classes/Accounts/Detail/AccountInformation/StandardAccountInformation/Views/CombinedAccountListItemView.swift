// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CombinedAccountListItemView.swift

import UIKit

final class CombinedAccountListItemView: UIView {
    
    // MARK: - Subviews
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()
    
    private let universalWalletContentView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private let walletIcon: CircleIconView = {
        let view = CircleIconView()
        view.image = .iconWallet
        view.padding = 8.0
        view.backgroundColor = .Layer.grayLighter
        return view
    }()
    
    private let walletNameLabel: UILabel = {
        let view = UILabel()
        view.textColor = .Text.main
        view.font = Fonts.DMSans.regular.make(15.0).uiFont
        return view
    }()
    
    private let verticalLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .Border.default
        return view
    }()
    
    private let scanButton = AddressScanButton()
    private let accountItemView = AccountListItemWithActionView()
    
    // MARK: - Properties
    
    var universalWalletName: String? {
        didSet { update(universalWalletName: universalWalletName) }
    }
    
    var onCopyButtonTap: (() -> Void)? {
        get { accountItemView.onCopyButtonTap }
        set { accountItemView.onCopyButtonTap = newValue }
    }
    
    var onScanButtonTap: (() -> Void)? {
        get { scanButton.onTap }
        set { scanButton.onTap = newValue }
    }
    
    // MARK: - Initialisers
    
    init() {
        super.init(frame: .zero)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setups
    
    private func setupConstraints() {
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        [walletIcon, walletNameLabel, verticalLineView, scanButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            universalWalletContentView.addSubview($0)
        }
        
        [universalWalletContentView, accountItemView].forEach {
            stackView.addArrangedSubview($0)
        }
        
        let constraints = [
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            walletIcon.topAnchor.constraint(equalTo: universalWalletContentView.topAnchor, constant: 18.0),
            walletIcon.leadingAnchor.constraint(equalTo: universalWalletContentView.leadingAnchor, constant: 16.0),
            walletIcon.widthAnchor.constraint(equalToConstant: 40.0),
            walletIcon.heightAnchor.constraint(equalToConstant: 40.0),
            walletNameLabel.leadingAnchor.constraint(equalTo: walletIcon.trailingAnchor, constant: 16.0),
            walletNameLabel.trailingAnchor.constraint(equalTo: universalWalletContentView.trailingAnchor, constant: -8.0),
            walletNameLabel.centerYAnchor.constraint(equalTo: walletIcon.centerYAnchor),
            verticalLineView.topAnchor.constraint(equalTo: walletIcon.bottomAnchor, constant: 6.0),
            verticalLineView.bottomAnchor.constraint(equalTo: universalWalletContentView.bottomAnchor, constant: -6.0),
            verticalLineView.centerXAnchor.constraint(equalTo: walletIcon.centerXAnchor),
            verticalLineView.widthAnchor.constraint(equalToConstant: 1.0),
            verticalLineView.heightAnchor.constraint(equalToConstant: 65.0),
            scanButton.topAnchor.constraint(equalTo: verticalLineView.topAnchor, constant: 5.0),
            scanButton.leadingAnchor.constraint(equalTo: verticalLineView.trailingAnchor, constant: 37.0)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Updates
    
    func update(theme: AccountListItemWithActionViewTheme) {
        accountItemView.customize(theme)
    }
    
    func update(accountViewModel: AccountInformationCopyAccountItemViewModel) {
        accountItemView.bindData(accountViewModel)
    }
    
    private func update(universalWalletName: String?) {
        universalWalletContentView.isHidden = universalWalletName == nil
        walletNameLabel.text = universalWalletName
    }
}
