//
//  AccountListView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AccountListViewDelegate: class {
    
    func accountListViewDidTapAddButton(_ accountListView: AccountListView)
}

class AccountListView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let imageViewTopInset: CGFloat = 10.0
        let accountListTopInset: CGFloat = 20.0
        let accountListBottomInset: CGFloat = -20.0
        let buttonBottomInset: CGFloat = 6.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components

    private lazy var topImageView = UIImageView(image: img("icon-modal-top"))
    
    private(set) lazy var accountsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        return collectionView
    }()
    
    private lazy var addButton = MainButton(title: "account-list-add".localized)
    
    weak var delegate: AccountListViewDelegate?
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    override func setListeners() {
        addButton.addTarget(self, action: #selector(notifyDelegateToAddButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTopImageViewLayout()
        setupAddButtonLayout()
        setupAccountCollectionViewLayout()
    }

    private func setupTopImageViewLayout() {
        addSubview(topImageView)
        
        topImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.imageViewTopInset)
        }
    }
    
    private func setupAddButtonLayout() {
        addSubview(addButton)
        
        addButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(layout.current.buttonBottomInset)
        }
    }
    
    private func setupAccountCollectionViewLayout() {
        addSubview(accountsCollectionView)
        
        accountsCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(topImageView.snp.bottom).offset(layout.current.accountListTopInset)
            make.bottom.equalTo(addButton.snp.top).offset(layout.current.accountListBottomInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    func notifyDelegateToAddButtonTapped() {
        delegate?.accountListViewDidTapAddButton(self)
    }
}
