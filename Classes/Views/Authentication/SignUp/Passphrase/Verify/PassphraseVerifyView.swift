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
//  PassPhraseVerifyView.swift

import UIKit
import MacaroonUIKit
import Foundation

final class PassphraseVerifyView: View {
    weak var delegate: PassphraseVerifyViewDelegate?
    
    private lazy var titleLabel = UILabel()
    private lazy var passphraseCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private lazy var nextButton = Button()

    func customize(_ theme: PassphraseVerifyViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addTitleLabel(theme)
        addCollectionView(theme)
        addNextButton(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func setListeners() {
        nextButton.addTarget(self, action: #selector(notifyDelegateToVerifyPassphrase), for: .touchUpInside)
    }
}

extension PassphraseVerifyView {
    private func addTitleLabel(_ theme: PassphraseVerifyViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.titleTopInset)
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
        }
    }
    
    private func addCollectionView(_ theme: PassphraseVerifyViewTheme) {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = theme.cellSpacing
        passphraseCollectionView.collectionViewLayout = collectionViewLayout
        passphraseCollectionView.register(
            PassphraseMnemonicCell.self,
            forCellWithReuseIdentifier: PassphraseMnemonicCell.reusableIdentifier
        )
        passphraseCollectionView.register(
            PasshraseMnemonicNumberHeaderSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PasshraseMnemonicNumberHeaderSupplementaryView.reusableIdentifier
        )
        passphraseCollectionView.backgroundColor = .clear
        passphraseCollectionView.allowsMultipleSelection = true
        passphraseCollectionView.isScrollEnabled = false

        addSubview(passphraseCollectionView)
        passphraseCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.listTopOffset)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(theme.listHeight)
        }
    }
    
    private func addNextButton(_ theme: PassphraseVerifyViewTheme) {
        nextButton.customize(theme.nextButtonTheme)
        nextButton.bindData(ButtonCommonViewModel(title: "title-next".localized))

        addSubview(nextButton)
        nextButton.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(passphraseCollectionView.snp.bottom).offset(theme.buttonVerticalInset)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.bottom.equalToSuperview().inset(safeAreaBottom + theme.buttonVerticalInset)
        }
    }
}

extension PassphraseVerifyView {
    func setDelegate(_ delegate: UICollectionViewDelegate?) {
        passphraseCollectionView.delegate = delegate
    }

    func setDataSource(_ dataSource: UICollectionViewDataSource?) {
        passphraseCollectionView.dataSource = dataSource
    }

    func setNextButtonEnabled(_ isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
    }

    func resetSelectionStatesAndReloadData() {
        passphraseCollectionView.indexPathsForSelectedItems?.forEach { passphraseCollectionView.deselectItem(at: $0, animated: false) }
        passphraseCollectionView.reloadData()
    }
}

extension PassphraseVerifyView {
    @objc
    private func notifyDelegateToVerifyPassphrase() {
        delegate?.passphraseVerifyViewDidVerifyPassphrase(self)
    }
}

protocol PassphraseVerifyViewDelegate: AnyObject {
    func passphraseVerifyViewDidVerifyPassphrase(_ passphraseVerifyView: PassphraseVerifyView)
}
