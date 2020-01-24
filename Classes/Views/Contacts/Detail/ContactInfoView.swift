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
    func contactInfoViewDidEditContactButton(_ contactInfoView: ContactInfoView)
    func contactInfoViewDidDeleteContactButton(_ contactInfoView: ContactInfoView)
}

class ContactInfoView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var userInformationView = UserInformationView(isEditable: false)
    
    private lazy var assetsTitleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 14.0)))
            .withTextColor(SharedColors.greenishGray)
            .withLine(.single)
            .withAlignment(.left)
            .withText("contacts-title-assets".localized)
    }()
    
    private(set) lazy var assetsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 5.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = .zero
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(ContactAssetCell.self, forCellWithReuseIdentifier: ContactAssetCell.reusableIdentifier)
        
        return collectionView
    }()
    
    private(set) lazy var editContactButton = MainButton(title: "contacts-edit-button".localized)
    
    private(set) lazy var deleteContactButton: MainButton = {
        let button = MainButton(title: "contacts-delete-contact".localized)
        button.setBackgroundImage(img("bg-black-button-big"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    weak var delegate: ContactInfoViewDelegate?
    
    override func linkInteractors() {
        userInformationView.delegate = self
    }
    
    override func setListeners() {
        editContactButton.addTarget(self, action: #selector(notifyDelegateToEditContactButtonTapped), for: .touchUpInside)
        deleteContactButton.addTarget(self, action: #selector(notifyDelegateToDeleteContactButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupUserInformationViewLayout()
        setupAssetsTitleLabelLayout()
        setupAssetsCollectionViewLayout()
        setupEditContactButtonLayout()
        setupDeleteContactButtonLayout()
    }
}

extension ContactInfoView {
    private func setupUserInformationViewLayout() {
        addSubview(userInformationView)
        
        userInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.height.equalTo(layout.current.informationViewHeight)
        }
    }
    
    private func setupAssetsTitleLabelLayout() {
        addSubview(assetsTitleLabel)
        
        assetsTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.assetsLabelHorizontalInset)
            make.top.equalTo(userInformationView.snp.bottom).offset(layout.current.verticalInset)
        }
    }
    
    private func setupAssetsCollectionViewLayout() {
        addSubview(assetsCollectionView)
        
        assetsCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(assetsTitleLabel.snp.bottom).offset(layout.current.collectionViewTopInset)
            make.height.equalTo(layout.current.collectionViewHeight)
        }
    }
    
    private func setupEditContactButtonLayout() {
        addSubview(editContactButton)
        
        editContactButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(assetsCollectionView.snp.bottom).offset(layout.current.assetsLabelHorizontalInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
        }
    }
    
    private func setupDeleteContactButtonLayout() {
        addSubview(deleteContactButton)
        
        deleteContactButton.snp.makeConstraints { make in
            make.top.equalTo(editContactButton.snp.bottom).offset(layout.current.deleteButtonTopInset)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(layout.current.verticalInset + safeAreaBottom)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
        }
    }
}

extension ContactInfoView {
    @objc
    private func notifyDelegateToEditContactButtonTapped() {
        delegate?.contactInfoViewDidEditContactButton(self)
    }
    
    @objc
    private func notifyDelegateToDeleteContactButtonTapped() {
        delegate?.contactInfoViewDidDeleteContactButton(self)
    }
}

extension ContactInfoView: UserInformationViewDelegate {
    func userInformationViewDidTapAddImageButton(_ userInformationView: UserInformationView) {
    }
    
    func userInformationViewDidTapQRCodeButton(_ userInformationView: UserInformationView) {
        delegate?.contactInfoViewDidTapQRCodeButton(self)
    }
}

extension ContactInfoView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let informationViewHeight: CGFloat = 333.0
        let verticalInset: CGFloat = 15.0
        let minimumInset: CGFloat = 10.0
        let assetsLabelHorizontalInset: CGFloat = 30.0
        let collectionViewHeight: CGFloat = 50.0
        let collectionViewTopInset: CGFloat = 7.0
        let deleteButtonTopInset: CGFloat = 10.0
        let buttonHorizontalInset: CGFloat = MainButton.Constants.horizontalInset
    }
}

extension ContactInfoView {
    private enum Colors {
        static let separatorColor = rgba(0.67, 0.67, 0.72, 0.31)
    }
}
