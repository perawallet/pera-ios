// Copyright 2022 Pera Wallet, LDA

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

final class PassphraseVerifyView:
    View,
    ViewModelBindable {
    weak var delegate: PassphraseVerifyViewDelegate?

    private lazy var titleLabel = Label()
    private lazy var firstCardView = PassphraseVerifyCardView()
    private lazy var secondCardView = PassphraseVerifyCardView()
    private lazy var thirdCardView = PassphraseVerifyCardView()
    private lazy var fourthCardView = PassphraseVerifyCardView()

    private lazy var nextButton = Button()
    
    private var choosenMnemonics: [Int: String] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setListeners()
        linkInteractors()
    }

    func customize(_ theme: PassphraseVerifyViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addTitleLabel(theme)
        addFirstCardView(theme)
        addSecondCardView(theme)
        addThirdCardView(theme)
        addFourthCardView(theme)
        addNextButton(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func setListeners() {
        nextButton.addTarget(
            self,
            action: #selector(didTapNextButton),
            for: .touchUpInside
        )
    }
    
    func linkInteractors() {
        firstCardView.delegate = self
        secondCardView.delegate = self
        thirdCardView.delegate = self
        fourthCardView.delegate = self
    }
    
    func bindData(_ viewModel: PassphraseVerifyViewModel?) {
        firstCardView.bindData(PassphraseVerifyCardViewModel(
            index: viewModel?.firstCardIndex,
            mnemonics: viewModel?.firstCardMnemonics)
        )
        secondCardView.bindData(PassphraseVerifyCardViewModel(
            index: viewModel?.secondCardIndex,
            mnemonics: viewModel?.secondCardMnemonics)
        )
        thirdCardView.bindData(PassphraseVerifyCardViewModel(
            index: viewModel?.thirdCardIndex,
            mnemonics: viewModel?.thirdCardMnemonics)
        )
        fourthCardView.bindData(PassphraseVerifyCardViewModel(
            index: viewModel?.fourthCardIndex,
            mnemonics: viewModel?.fourthCardMnemonics)
        )
    }
}

extension PassphraseVerifyView {
    private func addTitleLabel(_ theme: PassphraseVerifyViewTheme) {
        titleLabel.customizeAppearance(theme.title)
        titleLabel.editText = theme.titleText

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.titleTopInset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }
    
    private func addFirstCardView(_ theme: PassphraseVerifyViewTheme) {
        firstCardView.customize(PassphraseVerifyCardViewTheme())
        addSubview(firstCardView)
        firstCardView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.listTopOffset)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func addSecondCardView(_ theme: PassphraseVerifyViewTheme) {
        secondCardView.customize(PassphraseVerifyCardViewTheme())
        addSubview(secondCardView)
        secondCardView.snp.makeConstraints {
            $0.top.equalTo(firstCardView.snp.bottom).offset(theme.cardViewBottomOffset)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func addThirdCardView(_ theme: PassphraseVerifyViewTheme) {
        thirdCardView.customize(PassphraseVerifyCardViewTheme())
        addSubview(thirdCardView)
        thirdCardView.snp.makeConstraints {
            $0.top.equalTo(secondCardView.snp.bottom).offset(theme.cardViewBottomOffset)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func addFourthCardView(_ theme: PassphraseVerifyViewTheme) {
        fourthCardView.customize(PassphraseVerifyCardViewTheme())
        addSubview(fourthCardView)
        fourthCardView.snp.makeConstraints {
            $0.top.equalTo(thirdCardView.snp.bottom).offset(theme.cardViewBottomOffset)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func addNextButton(_ theme: PassphraseVerifyViewTheme) {
        nextButton.customize(theme.nextButtonTheme)
        nextButton.bindData(ButtonCommonViewModel(title: "title-next".localized))
        nextButton.isEnabled = false

        addSubview(nextButton)
        nextButton.snp.makeConstraints {
            $0.top.equalTo(fourthCardView.snp.bottom).offset(theme.buttonTopOffset)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.bottom.equalToSuperview().inset(safeAreaBottom + theme.buttonVerticalInset)
        }
    }
}

extension PassphraseVerifyView {
    func reset() {
        choosenMnemonics.removeAll()
        firstCardView.reset()
        secondCardView.reset()
        thirdCardView.reset()
        fourthCardView.reset()
        nextButton.isEnabled = false
    }
}

extension PassphraseVerifyView {
    @objc
    private func didTapNextButton() {
        choosenMnemonics[firstCardView.getIndex()] = firstCardView.getMnemonic()
        choosenMnemonics[secondCardView.getIndex()] = secondCardView.getMnemonic()
        choosenMnemonics[thirdCardView.getIndex()] = thirdCardView.getMnemonic()
        choosenMnemonics[fourthCardView.getIndex()] = fourthCardView.getMnemonic()
        
        delegate?.passphraseVerifyViewDidTapNextButton(
            self,
            mnemonics: choosenMnemonics
        )
    }
}

extension PassphraseVerifyView: PassphraseVerifyCardViewDelegate {
    func passphraseVerifyCardViewDidSelectWord(
        _ passphraseVerifyCardView: PassphraseVerifyCardView,
        index: Int,
        word: String
    ) {
        if firstCardView.isSelected &&
            secondCardView.isSelected &&
            thirdCardView.isSelected &&
            fourthCardView.isSelected {
            nextButton.isEnabled = true
        }
    }
}

protocol PassphraseVerifyViewDelegate: AnyObject {
    func passphraseVerifyViewDidTapNextButton(
        _ passphraseVerifyView: PassphraseVerifyView,
        mnemonics: [Int: String]
    )
}
