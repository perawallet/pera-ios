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
//  PassPhraseBackUpView.swift

import UIKit
import Macaroon

final class PassphraseView: View {
    weak var delegate: PassphraseBackUpViewDelegate?

    private lazy var titleLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    private lazy var passphraseContainerView = UIView()
    private lazy var passphraseCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 8.0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(PassphraseBackUpCell.self, forCellWithReuseIdentifier: PassphraseBackUpCell.reusableIdentifier)
        return collectionView
    }()
    
    private(set) lazy var verifyButton = Button()

    func customize(_ theme: PassphraseViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addTitleLabel(theme)
        addDescriptionLabel(theme)
        addPassphraseContainerView(theme)
        addPassphraseCollectionView(theme)
        addVerifyButton(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func setListeners() {
        verifyButton.addTarget(self, action: #selector(notifyDelegateToActionButtonTapped), for: .touchUpInside)
    }
}

extension PassphraseView {
    @objc
    func notifyDelegateToActionButtonTapped() {
        delegate?.passphraseViewDidTapActionButton(self)
    }
}

extension PassphraseView {
    private func addTitleLabel(_ theme: PassphraseViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.titleHorizontalInset)
            $0.top.equalToSuperview().inset(theme.topInset)
        }
    }

    private func addDescriptionLabel(_ theme: PassphraseViewTheme) {
        descriptionLabel.customizeAppearance(theme.description)

        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.bottomInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addPassphraseContainerView(_ theme: PassphraseViewTheme) {
        passphraseContainerView.customizeAppearance(theme.passphraseContainerView)
        passphraseContainerView.layer.cornerRadius = theme.passphraseContainerCorner.radius

        addSubview(passphraseContainerView)
        passphraseContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(theme.containerTopInset)
            $0.height.equalTo(theme.collectionViewHeight)
        }
    }
    
    private func addPassphraseCollectionView(_ theme: PassphraseViewTheme) {
        passphraseContainerView.addSubview(passphraseCollectionView)
        
        passphraseCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.collectionViewHorizontalInset)
            $0.top.bottom.equalToSuperview().inset(theme.verticalInset)
        }
    }

    private func addVerifyButton(_ theme: PassphraseViewTheme) {
        verifyButton.customize(theme.mainButtonTheme)
        verifyButton.bindData(ButtonCommonViewModel(title: "title-next".localized))

        addSubview(verifyButton)
        verifyButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.greaterThanOrEqualTo(descriptionLabel.snp.bottom).offset(theme.containerTopInset)
            make.bottom.equalToSuperview().inset(theme.bottomInset + safeAreaBottom)
            make.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }
}

extension PassphraseView {
    func setDelegate(_ delegate: UICollectionViewDelegate?) {
        passphraseCollectionView.delegate = delegate
    }

    func setDataSource(_ dataSource: UICollectionViewDataSource?) {
        passphraseCollectionView.dataSource = dataSource
    }
}

extension Colors {
    fileprivate enum PassphraseView {
        static let containerBackground = color("passphraseContainerBackground")
    }
}

protocol PassphraseBackUpViewDelegate: AnyObject {
    func passphraseViewDidTapActionButton(_ passphraseView: PassphraseView)
}
