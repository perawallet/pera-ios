//
//  ContactInfoView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 30.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ContactInfoView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: ContactInfoViewDelegate?
    
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
        flowLayout.minimumLineSpacing = 8.0
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
    
    private(set) lazy var shareButton: AlignedButton = {
        let positions: AlignedButton.StylePositionAdjustment = (image: CGPoint(x: 30.0, y: 0.0), title: CGPoint(x: 4.0, y: 0.0))
        let button = AlignedButton(style: .imageLeftTitleCentered(positions))
        button.setTitle("title-share".localized, for: .normal)
        button.setTitleColor(SharedColors.primaryText, for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 16.0))
        button.backgroundColor = SharedColors.white
        button.layer.cornerRadius = 26.0
        button.setImage(img("icon-share", isTemplate: true), for: .normal)
        button.tintColor = SharedColors.gray700
        return button
    }()
    
    override func linkInteractors() {
        userInformationView.delegate = self
    }
    
    override func setListeners() {
        shareButton.addTarget(self, action: #selector(notifyDelegateToShareContact), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupUserInformationViewLayout()
        setupAssetsTitleLabelLayout()
        setupAssetsCollectionViewLayout()
        setupShareButtonLayout()
    }
}

extension ContactInfoView {
    private func setupUserInformationViewLayout() {
        addSubview(userInformationView)
        
        userInformationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
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
    
    private func setupShareButtonLayout() {
        addSubview(shareButton)
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(assetsCollectionView.snp.bottom).offset(layout.current.shareButtonTopInset)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.verticalInset + safeAreaBottom)
            make.size.equalTo(layout.current.buttonSize)
        }
    }
}

extension ContactInfoView {
    @objc
    private func notifyDelegateToShareContact() {
        delegate?.contactInfoViewDidTapShareButton(self)
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
        let verticalInset: CGFloat = 20.0
        let assetsLabelHorizontalInset: CGFloat = 20.0
        let collectionViewHeight: CGFloat = 50.0
        let collectionViewTopInset: CGFloat = 8.0
        let shareButtonTopInset: CGFloat = 30.0
        let buttonSize = CGSize(width: 160.0, height: 52.0)
    }
}

protocol ContactInfoViewDelegate: class {
    func contactInfoViewDidTapQRCodeButton(_ contactInfoView: ContactInfoView)
    func contactInfoViewDidTapShareButton(_ contactInfoView: ContactInfoView)
}
