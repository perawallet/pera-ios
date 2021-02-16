// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  PassphraseDisplayView.swift

import UIKit

class PassphraseDisplayView: BaseView {
    
    weak var delegate: PassphraseDisplayViewDelegate? {
        didSet {
            passphraseCollectionView.delegate = delegate as? UICollectionViewDelegateFlowLayout
            passphraseCollectionView.dataSource = delegate as? UICollectionViewDataSource
        }
    }
    
    private let layout = Layout<LayoutConstants>()
    
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
        collectionView.backgroundColor = Colors.Background.secondary
        collectionView.register(PassphraseBackUpCell.self, forCellWithReuseIdentifier: PassphraseBackUpCell.reusableIdentifier)
        return collectionView
    }()
    
    private(set) lazy var qrButton: AlignedButton = {
        let button = AlignedButton(.imageAtLeft(spacing: 4.0))
        button.setImage(img("icon-qr-show", isTemplate: true), for: .normal)
        button.tintColor = Colors.Text.tertiary
        button.setTitle("back-up-phrase-qr".localized, for: .normal)
        button.setTitleColor(Colors.Text.primary, for: .normal)
        button.setBackgroundImage(img("bg-light-gray-button-small"), for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 16.0))
        return button
    }()
    
    private(set) lazy var shareButton: AlignedButton = {
        let button = AlignedButton(.imageAtLeft(spacing: 4.0))
        button.setImage(img("icon-share-24", isTemplate: true), for: .normal)
        button.tintColor = Colors.Text.tertiary
        button.setTitle("title-share-qr".localized, for: .normal)
        button.setBackgroundImage(img("bg-light-gray-button-small"), for: .normal)
        button.setTitleColor(Colors.Text.primary, for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 16.0))
        return button
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func setListeners() {
        shareButton.addTarget(self, action: #selector(notifyDelegateToShareButtonTapped), for: .touchUpInside)
        qrButton.addTarget(self, action: #selector(notifyDelegateToQrButtonTapped), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupPassphraseCollectionViewLayout()
        setupShareButtonLayout()
        setupQrButtonLayout()
    }
}

extension PassphraseDisplayView {
    @objc
    func notifyDelegateToShareButtonTapped() {
        delegate?.passphraseViewDidShare(self)
    }
    
    @objc
    func notifyDelegateToQrButtonTapped() {
        delegate?.passphraseViewDidOpenQR(self)
    }
}

extension PassphraseDisplayView {
    private func setupPassphraseCollectionViewLayout() {
        addSubview(passphraseCollectionView)
        
        passphraseCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.collectionViewHorizontalInset)
            make.top.equalToSuperview().inset(layout.current.passPhraseCollectionViewVerticalInset)
            make.height.equalTo(layout.current.collectionViewHeight)
        }
    }
    
    private func setupShareButtonLayout() {
        addSubview(shareButton)
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(passphraseCollectionView.snp.bottom).offset(layout.current.buttonTopInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.bottomInset + safeAreaBottom)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.size.equalTo(layout.current.buttonSize)
        }
    }
    
    private func setupQrButtonLayout() {
        addSubview(qrButton)
        
        qrButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.size.equalTo(shareButton)
            make.top.bottom.equalTo(shareButton)
            make.trailing.greaterThanOrEqualTo(shareButton.snp.leading).offset(-layout.current.horizontalInset)
            make.centerY.equalTo(shareButton)
        }
    }
}

extension PassphraseDisplayView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0 * horizontalScale
        let passPhraseCollectionViewVerticalInset: CGFloat = 16.0
        let collectionViewHorizontalInset: CGFloat = 20.0 * horizontalScale
        let buttonTopInset: CGFloat = 27.0
        let bottomInset: CGFloat = 16.0
        let collectionViewHeight: CGFloat = 315.0
        let buttonSize = CGSize(width: 157.0 * horizontalScale, height: 52.0)
    }
}

protocol PassphraseDisplayViewDelegate: class {
    func passphraseViewDidShare(_ passphraseDisplayView: PassphraseDisplayView)
    func passphraseViewDidOpenQR(_ passphraseDisplayView: PassphraseDisplayView)
}
