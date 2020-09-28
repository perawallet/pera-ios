//
//  AccountTypeSelectionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class AccountTypeSelectionView: BaseView {
    
    weak var delegate: AccountTypeSelectionViewDelegate?
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        stackView.spacing = 0.0
        stackView.alignment = .fill
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.axis = .vertical
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    private lazy var createNewAccountView = AccountTypeView()
    
    private lazy var watchAccountView = AccountTypeView()
    
    private lazy var recoverAccountView = AccountTypeView()
    
    private lazy var pairAccountView = AccountTypeView()

    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func setListeners() {
        createNewAccountView.addTarget(self, action: #selector(notifyDelegateToSelectCreateNewAccount), for: .touchUpInside)
        watchAccountView.addTarget(self, action: #selector(notifyDelegateToSelectWatchAccount), for: .touchUpInside)
        recoverAccountView.addTarget(self, action: #selector(notifyDelegateToSelectRecoverAccount), for: .touchUpInside)
        pairAccountView.addTarget(self, action: #selector(notifyDelegateToSelectPairAccount), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupStackViewLayout()
    }
}

extension AccountTypeSelectionView {
    @objc
    private func notifyDelegateToSelectCreateNewAccount() {
        delegate?.accountTypeSelectionView(self, didSelect: .create)
    }
    
    @objc
    private func notifyDelegateToSelectWatchAccount() {
        delegate?.accountTypeSelectionView(self, didSelect: .watch)
    }
    
    @objc
    private func notifyDelegateToSelectRecoverAccount() {
        delegate?.accountTypeSelectionView(self, didSelect: .recover)
    }
    
    @objc
    private func notifyDelegateToSelectPairAccount() {
        delegate?.accountTypeSelectionView(self, didSelect: .pair)
    }
}

extension AccountTypeSelectionView {
    private func setupStackViewLayout() {
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        stackView.addArrangedSubview(createNewAccountView)
        stackView.addArrangedSubview(watchAccountView)
        stackView.addArrangedSubview(recoverAccountView)
        stackView.addArrangedSubview(pairAccountView)
    }
}

extension AccountTypeSelectionView {
    func configureCreateNewAccountView(with viewModel: AccountTypeViewModel) {
        createNewAccountView.bind(viewModel)
    }
    
    func configureWatchAccountView(with viewModel: AccountTypeViewModel) {
        watchAccountView.bind(viewModel)
    }
    
    func configureRecoverAccountView(with viewModel: AccountTypeViewModel) {
        recoverAccountView.bind(viewModel)
    }
    
    func configurePairAccountView(with viewModel: AccountTypeViewModel) {
        pairAccountView.bind(viewModel)
    }
}

protocol AccountTypeSelectionViewDelegate: class {
    func accountTypeSelectionView(_ accountTypeSelectionView: AccountTypeSelectionView, didSelect mode: AccountSetupMode)
}
