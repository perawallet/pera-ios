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
        view.backgroundColor = SharedColors.secondaryBackground
        return view
    }()
    
    private(set) lazy var passphraseCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = .zero
        flowLayout.minimumLineSpacing = 13.0
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
        let positions: AlignedButton.StylePositionAdjustment = (image: CGPoint(x: 0.0, y: 0.0), title: CGPoint(x: 4.0, y: 0.0))
        let button = AlignedButton(style: .imageLeftTitleCentered(positions))
        button.setImage(img("icon-share"), for: .normal)
        button.setTitle("title-share".localized, for: .normal)
        button.setTitleColor(SharedColors.tertiaryText, for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 14.0))
        return button
    }()
    
    private(set) lazy var qrButton: AlignedButton = {
        let positions: AlignedButton.StylePositionAdjustment = (image: CGPoint(x: 0.0, y: 0.0), title: CGPoint(x: 4.0, y: 0.0))
        let button = AlignedButton(style: .imageLeftTitleCentered(positions))
        button.setImage(img("icon-show-qr"), for: .normal)
        button.setTitle("back-up-phrase-qr".localized, for: .normal)
        button.setTitleColor(SharedColors.tertiaryText, for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 14.0))
        return button
    }()
    
    private lazy var informationImageView = UIImageView(image: img("icon-info-gray"))
    
    private(set) lazy var warningLabel: UILabel = {
        UILabel()
            .withLine(.contained)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withText("back-up-phrase-warning".localized)
            .withAttributedText("back-up-phrase-warning".localized.attributed([.lineSpacing(1.2), .textColor(SharedColors.primaryText)]))
            .withAlignment(.left)
    }()
    
    private lazy var verifyButton = MainButton(title: "back-up-phrase-button-title".localized)
    
    override func configureAppearance() {
        super.configureAppearance()
        setShadow()
    }
    
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
        setupInformationImageViewLayout()
        setupWarningLabelLayout()
        setupVerifyButtonLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
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
            make.height.equalTo(layout.current.collectionViewHeight)
        }
    }
    
    private func setupShareButtonLayout() {
        passphraseContainerView.addSubview(shareButton)
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(passphraseCollectionView.snp.bottom).offset(layout.current.warningLabelVerticalInset)
            make.bottom.equalToSuperview().inset(layout.current.horizontalInset)
            make.trailing.equalToSuperview().inset(layout.current.shareTrailingInset)
        }
    }
    
    private func setupQrButtonLayout() {
        passphraseContainerView.addSubview(qrButton)
        
        qrButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(passphraseCollectionView.snp.bottom).offset(layout.current.warningLabelVerticalInset)
            make.centerY.equalTo(shareButton)
        }
    }
    
    private func setupInformationImageViewLayout() {
        addSubview(informationImageView)
        
        informationImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.size.equalTo(layout.current.infoIconSize)
            make.top.equalTo(passphraseContainerView.snp.bottom).offset(layout.current.informationTopOffset)
        }
    }
    
    private func setupWarningLabelLayout() {
        addSubview(warningLabel)
        
        warningLabel.snp.makeConstraints { make in
            make.leading.equalTo(informationImageView.snp.trailing).offset(layout.current.informationLabelLeading)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalTo(passphraseContainerView.snp.bottom).offset(layout.current.informationTopOffset)
        }
    }
    
    private func setupVerifyButtonLayout() {
        addSubview(verifyButton)
        
        verifyButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(warningLabel.snp.bottom).offset(layout.current.buttonMinimumTopInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension PassphraseView {
    private func setShadow() {
        layer.shadowColor = rgba(0.26, 0.26, 0.31, 0.07).cgColor
        layer.shadowOpacity = 1.0
        layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        layer.shadowRadius = 12.0
    }
}

extension PassphraseView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0 * horizontalScale
        let passPhraseContainerViewTopInset: CGFloat = 60.0
        let shareTrailingInset: CGFloat = 25.0 * horizontalScale
        let passPhraseCollectionViewVerticalInset: CGFloat = 21.0
        let containerViewHorizontalInset: CGFloat = 20.0 * horizontalScale
        let collectionViewHorizontalInset: CGFloat = 20.0 * horizontalScale
        let warningLabelVerticalInset: CGFloat = 29.0
        let collectionViewHeight: CGFloat = 316.0
        let bottomInset: CGFloat = 55.0
        let buttonMinimumTopInset: CGFloat = 60.0
        let informationTopOffset: CGFloat = 28.0
        let infoIconSize = CGSize(width: 24.0, height: 24.0)
        let informationLabelLeading: CGFloat = 12.0
    }
}

protocol PassphraseBackUpViewDelegate: class {
    func passphraseViewDidTapActionButton(_ passphraseView: PassphraseView)
    func passphraseViewDidTapShareButton(_ passphraseView: PassphraseView)
    func passphraseViewDidTapQrButton(_ passphraseView: PassphraseView)
}
