//
//  PassPhraseBackUpView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol PassPhraseBackUpViewDelegate: class {
    
    func passPhraseBackUpViewDidTapVerifyButton(_ passPhraseBackUpView: PassPhraseBackUpView)
    func passPhraseBackUpViewDidTapShareButton(_ passPhraseBackUpView: PassPhraseBackUpView)
    func passPhraseBackUpViewDidTapQrButton(_ passPhraseBackUpView: PassPhraseBackUpView)
}

class PassPhraseBackUpView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 69.0 * verticalScale
        let horizontalInset: CGFloat = 25.0
        let passPhraseContainerViewTopInset: CGFloat = 43.0
        let passPhraseCollectionViewVerticalInset: CGFloat = 16.5
        let containerViewHorizontalInset: CGFloat = 25.0 * horizontalScale
        let collectionViewHorizontalInset: CGFloat = 25.0 * horizontalScale
        let warningContainerViewTopInset: CGFloat = 24.0
        let warningHorizontalInset: CGFloat = 20.0
        let warningImageCenterOffset: CGFloat = 5.0
        let warningLabelVerticalInset: CGFloat = 20.0
        let bottomInset: CGFloat = 55.0
        let buttonMinimumTopInset: CGFloat = 20.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.center)
            .withTextColor(SharedColors.black)
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 20.0)))
            .withText("back-up-phrase-title".localized)
    }()
    
    private lazy var passPhraseContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20.0
        view.backgroundColor = .white
        return view
    }()
    
    private(set) lazy var passphraseCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = .zero
        flowLayout.minimumLineSpacing = 5.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .zero
        collectionView.backgroundColor = .white
        
        collectionView.register(PassphraseBackUpCell.self, forCellWithReuseIdentifier: PassphraseBackUpCell.reusableIdentifier)
        
        return collectionView
    }()
    
    private(set) lazy var shareButton: AlignedButton = {
        let positions: AlignedButton.StylePositionAdjustment = (image: CGPoint(x: 4.5, y: 0.0), title: CGPoint(x: -4.5, y: 0.0))
        
        let button = AlignedButton(style: .imageRight(positions))
        button.setImage(img("icon-share"), for: .normal)
        button.setTitle("title-share".localized, for: .normal)
        button.setTitleColor(SharedColors.purple, for: .normal)
        button.titleLabel?.font = UIFont.font(.overpass, withWeight: .semiBold(size: 13.0))
        return button
    }()
    
    private(set) lazy var qrButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = SharedColors.purple
        button.setImage(img("icon-qr-code-white", isTemplate: true), for: .normal)
        return button
    }()
    
    private lazy var warningContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20.0
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var warningImageView = UIImageView(image: img("icon-warning"))
    
    private lazy var warningLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.contained)
            .withTextColor(SharedColors.darkGray)
            .withFont(UIFont.font(.avenir, withWeight: .medium(size: 11.0)))
            .withText("back-up-phrase-warning".localized)
        
    }()
    
    private lazy var verifyButton: MainButton = {
        let button = MainButton(title: "back-up-phrase-button-title".localized)
        return button
    }()
    
    weak var delegate: PassPhraseBackUpViewDelegate?
    
    // MARK: Configuration
    
    override func setListeners() {
        shareButton.addTarget(self, action: #selector(notifyDelegateToShareButtonTapped), for: .touchUpInside)
        qrButton.addTarget(self, action: #selector(notifyDelegateToQrButtonTapped), for: .touchUpInside)
        verifyButton.addTarget(self, action: #selector(notifyDelegateToVerifyButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupPassPhraseContainerViewLayout()
        setupPassphraseCollectionViewLayout()
        setupShareButtonLayout()
        setupQrButtonLayout()
        setupWarningContainerViewLayout()
        setupWarningImageViewLayout()
        setupWarningLabelLayout()
        setupVerifyButtonLayout()
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupPassPhraseContainerViewLayout() {
        addSubview(passPhraseContainerView)
        
        passPhraseContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.containerViewHorizontalInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.passPhraseContainerViewTopInset)
        }
    }
    
    private func setupPassphraseCollectionViewLayout() {
        passPhraseContainerView.addSubview(passphraseCollectionView)
        
        passphraseCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.collectionViewHorizontalInset)
            make.top.equalToSuperview().inset(layout.current.passPhraseCollectionViewVerticalInset)
            make.height.equalTo(238.0)
        }
    }
    
    private func setupShareButtonLayout() {
        passPhraseContainerView.addSubview(shareButton)
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(passphraseCollectionView.snp.bottom).offset(layout.current.warningLabelVerticalInset)
            make.bottom.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupQrButtonLayout() {
        passPhraseContainerView.addSubview(qrButton)
        
        qrButton.snp.makeConstraints { make in
            make.top.equalTo(passphraseCollectionView.snp.bottom).offset(layout.current.warningLabelVerticalInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalTo(shareButton)
            make.height.width.equalTo(20)
        }
    }
    
    private func setupWarningContainerViewLayout() {
        addSubview(warningContainerView)
        
        warningContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(passPhraseContainerView.snp.bottom).offset(layout.current.warningContainerViewTopInset)
        }
    }
    
    private func setupWarningImageViewLayout() {
        warningContainerView.addSubview(warningImageView)
        
        warningImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.warningHorizontalInset)
            make.centerY.equalToSuperview().offset(layout.current.warningImageCenterOffset)
        }
    }
    
    private func setupWarningLabelLayout() {
        warningContainerView.addSubview(warningLabel)
        
        warningLabel.snp.makeConstraints { make in
            make.leading.equalTo(warningImageView.snp.trailing).offset(layout.current.warningHorizontalInset)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.bottom.equalToSuperview().inset(layout.current.warningLabelVerticalInset)
        }
    }
    
    private func setupVerifyButtonLayout() {
        addSubview(verifyButton)
        
        verifyButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(warningContainerView.snp.bottom).offset(layout.current.buttonMinimumTopInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    func notifyDelegateToShareButtonTapped() {
        delegate?.passPhraseBackUpViewDidTapShareButton(self)
    }
    
    @objc
    func notifyDelegateToQrButtonTapped() {
        delegate?.passPhraseBackUpViewDidTapQrButton(self)
    }
    
    @objc
    func notifyDelegateToVerifyButtonTapped() {
        delegate?.passPhraseBackUpViewDidTapVerifyButton(self)
    }
}
