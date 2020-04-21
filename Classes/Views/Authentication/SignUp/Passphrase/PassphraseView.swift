//
//  PassPhraseBackUpView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassphraseView: BaseView {
    
    weak var delegate: PassphraseBackUpViewDelegate?
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var passphraseContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12.0
        view.backgroundColor = color("secondaryBackground")
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
    
    private(set) lazy var qrButton: AlignedButton = {
        let positions: AlignedButton.StylePositionAdjustment = (image: CGPoint(x: 4.5, y: 0.0), title: CGPoint(x: -4.5, y: 0.0))
        let button = AlignedButton(style: .imageRight(positions))
        button.setImage(img("icon-share"), for: .normal)
        button.setTitle("title-share".localized, for: .normal)
        button.setTitleColor(SharedColors.purple, for: .normal)
        button.titleLabel?.font = UIFont.font(.overpass, withWeight: .semiBold(size: 13.0))
        return button
    }()
    
    private lazy var informationImageView = UIImageView(image: img(""))
    
    private(set) lazy var warningLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 11.0)))
            .withText("back-up-phrase-warning".localized)
            .withAttributedText("back-up-phrase-warning".localized.attributed([.lineSpacing(1.5), .textColor(.white)]))
            .withAlignment(.left)
    }()
    
    private lazy var verifyButton = MainButton(title: "back-up-phrase-button-title".localized)
    
    override func setListeners() {
        shareButton.addTarget(self, action: #selector(notifyDelegateToShareButtonTapped), for: .touchUpInside)
        qrButton.addTarget(self, action: #selector(notifyDelegateToQrButtonTapped), for: .touchUpInside)
        verifyButton.addTarget(self, action: #selector(notifyDelegateToActionButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupPassphraseContainerViewLayout()
        setupPassphraseCollectionViewLayout()
        setupShareButtonLayout()
        setupQrButtonLayout()
        setupWarningLabelLayout()
        setupVerifyButtonLayout()
    }
}

extension PassphraseView {
    @objc
    func notifyDelegateToShareButtonTapped() {
        delegate?.passphraseViewDidTapShareButton(self)
    }
    
    @objc
    func notifyDelegateToQrButtonTapped() {
        delegate?.passphraseViewDidTapQrButton(self)
    }
    
    @objc
    func notifyDelegateToActionButtonTapped() {
        delegate?.passphraseViewDidTapActionButton(self)
    }
}

extension PassphraseView {
    private func setupPassphraseContainerViewLayout() {
        addSubview(passphraseContainerView)
        
        passphraseContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.containerViewHorizontalInset)
            make.top.equalToSuperview().inset(layout.current.passPhraseContainerViewTopInset)
        }
    }
    
    private func setupPassphraseCollectionViewLayout() {
        passphraseContainerView.addSubview(passphraseCollectionView)
        
        passphraseCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.collectionViewHorizontalInset)
            make.top.equalToSuperview().inset(layout.current.passPhraseCollectionViewVerticalInset)
            make.height.equalTo(238.0)
        }
    }
    
    private func setupShareButtonLayout() {
        passphraseContainerView.addSubview(shareButton)
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(passphraseCollectionView.snp.bottom).offset(layout.current.warningLabelVerticalInset)
            make.bottom.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupQrButtonLayout() {
        passphraseContainerView.addSubview(qrButton)
        
        qrButton.snp.makeConstraints { make in
            make.top.equalTo(passphraseCollectionView.snp.bottom).offset(layout.current.warningLabelVerticalInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.centerY.equalTo(shareButton)
            make.height.width.equalTo(20)
        }
    }
    
    private func setupWarningLabelLayout() {
        addSubview(warningLabel)
        
        warningLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.titleHorizontalInset)
            make.top.bottom.equalToSuperview().inset(layout.current.warningLabelVerticalInset)
        }
    }
    
    private func setupVerifyButtonLayout() {
        addSubview(verifyButton)
        
        verifyButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(warningLabel.snp.bottom).offset(layout.current.buttonMinimumTopInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
        }
    }
}

extension PassphraseView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 69.0 * verticalScale
        let horizontalInset: CGFloat = 25.0
        let titleHorizontalInset: CGFloat = 17.0
        let passPhraseContainerViewTopInset: CGFloat = 43.0
        let passPhraseCollectionViewVerticalInset: CGFloat = 16.5
        let containerViewHorizontalInset: CGFloat = 15.0 * horizontalScale
        let collectionViewHorizontalInset: CGFloat = 25.0 * horizontalScale
        let warningContainerViewTopInset: CGFloat = 24.0
        let warningLabelVerticalInset: CGFloat = 20.0
        let bottomInset: CGFloat = 55.0
        let buttonMinimumTopInset: CGFloat = 60.0
        let buttonHorizontalInset: CGFloat = MainButton.Constants.horizontalInset
    }
}

protocol PassphraseBackUpViewDelegate: class {
    func passphraseViewDidTapActionButton(_ passphraseView: PassphraseView)
    func passphraseViewDidTapShareButton(_ passphraseView: PassphraseView)
    func passphraseViewDidTapQrButton(_ passphraseView: PassphraseView)
}
