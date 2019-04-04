//
//  ContactInfoView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol ContactInfoViewDelegate: class {
    
    func contactInfoViewDidTapQRCodeButton(_ contactInfoView: ContactInfoView)
}

class ContactInfoView: BaseView {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let informationViewHeight: CGFloat = 333.0
        let bottomInset: CGFloat = 20.0
        let topInset: CGFloat = 24.0
        let transactionLabelVerticalInset: CGFloat = 34.0
        let transactionLabelHorizontalInset: CGFloat = 25.0
        let transactionsCollectionViewVerticalInset: CGFloat = 7.0
        let minimumHeight: CGFloat = 300.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var userInformationView: UserInformationView = {
        let view = UserInformationView(isEditable: false)
        return view
    }()
    
    private lazy var transactionTitleLabel: UILabel = {
        UILabel()
            .withText("contacts-transactions-title".localized)
            .withTextColor(SharedColors.darkGray)
            .withAlignment(.left)
            .withFont(UIFont.font(.opensans, withWeight: .semiBold(size: 12.0)))
    }()
    
    private(set) lazy var transactionsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .white
        collectionView.contentInset = .zero
        
        collectionView.register(TransactionHistoryCell.self, forCellWithReuseIdentifier: TransactionHistoryCell.reusableIdentifier)
        
        return collectionView
    }()
    
    private lazy var contentStateView = ContentStateView()
    
    weak var delegate: ContactInfoViewDelegate?
    
    // MARK: Setup
    
    override func linkInteractors() {
        userInformationView.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupUserInformationViewLayout()
        setupTransactionsLabelLayout()
        setupTransactionsCollectionViewLayout()
    }
    
    private func setupUserInformationViewLayout() {
        addSubview(userInformationView)
        
        userInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(layout.current.topInset)
            make.height.equalTo(layout.current.informationViewHeight)
        }
    }
    
    private func setupTransactionsLabelLayout() {
        addSubview(transactionTitleLabel)
        
        transactionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(userInformationView.snp.bottom).offset(layout.current.transactionLabelVerticalInset)
            make.leading.equalToSuperview().inset(layout.current.transactionLabelHorizontalInset)
        }
    }
    
    private func setupTransactionsCollectionViewLayout() {
        addSubview(transactionsCollectionView)
        
        transactionsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(transactionTitleLabel.snp.bottom).offset(layout.current.transactionsCollectionViewVerticalInset)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.minimumHeight)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(layout.current.bottomInset)
        }
        
        transactionsCollectionView.backgroundView = contentStateView
    }
}

extension ContactInfoView: UserInformationViewDelegate {
    
    func userInformationViewDidTapAddImageButton(_ userInformationView: UserInformationView) {
    }
    
    func userInformationViewDidTapQRCodeButton(_ userInformationView: UserInformationView) {
        delegate?.contactInfoViewDidTapQRCodeButton(self)
    }
}
