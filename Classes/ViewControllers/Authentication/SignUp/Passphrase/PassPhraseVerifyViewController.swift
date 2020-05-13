//
//  PassphraseVerifyViewController.swift
//  algorand
//
//  Created by Omer Emre Aslan on 25.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassphraseVerifyViewController: BaseScrollViewController {
    
    private lazy var bottomModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 358.0))
    )
    
    private lazy var passphraseViewModel: PassphraseViewModel? = {
        if let privateKey = session?.privateData(for: "temp") {
            return PassphraseViewModel(privateKey: privateKey)
        }
        return nil
    }()
    
    private(set) lazy var passphraseVerifyView = PassphraseVerifyView()
    
    override func configureAppearance() {
        super.configureAppearance()
        view.backgroundColor = SharedColors.primaryBackground
        updatePassPhraseLabel()
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        passphraseVerifyView.passphraseCollectionView.delegate = self
        passphraseVerifyView.passphraseCollectionView.dataSource = self
        (passphraseVerifyView.passphraseCollectionView.collectionViewLayout as? LeftAlignedCollectionViewFlowLayout)?.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupPassphraseViewLayout()
    }
}

extension PassphraseVerifyViewController {
    private func setupPassphraseViewLayout() {
        contentView.addSubview(passphraseVerifyView)
        
        passphraseVerifyView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

extension PassphraseVerifyViewController {
    private func updatePassPhraseLabel() {
        let currentIndex = passphraseViewModel?.currentIndex.advanced(by: 1) ?? 1
        let currentIndexValue = passphraseViewModel?.currentIndexValue().advanced(by: 1) ?? 0
        
        let currentIndexString: String
        
        switch currentIndexValue {
        case 1:
            currentIndexString = "\(currentIndexValue)st"
        case 2:
            currentIndexString = "\(currentIndexValue)nd"
        case 3:
            currentIndexString = "\(currentIndexValue)rd"
        default:
            currentIndexString = "\(currentIndexValue)th"
        }
        
        let titleText = "Question \(currentIndex) of \(passphraseViewModel?.numberOfValidations ?? 0)".localized
        let subtitleText = "Select the \(currentIndexString) word of your passphrase".localized
        
        title = titleText
        passphraseVerifyView.questionTitleLabel.text = subtitleText
    }
}

extension PassphraseVerifyViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return passphraseViewModel?.numberOfMnemonic() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let mnemonic = passphraseViewModel?.mnemonic(atIndex: indexPath.item),
            let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PassphraseCollectionViewCell.reusableIdentifier,
            for: indexPath) as? PassphraseCollectionViewCell else {
                fatalError("Index path is out of bounds")
        }
        
        cell.contextView.phraseLabel.text = mnemonic
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = passphraseViewModel,
            let mnemonic = viewModel.mnemonic(atIndex: indexPath.item),
            let cell = collectionView.cellForItem(at: indexPath) as? PassphraseCollectionViewCell else {
                fatalError("Index path is out of bounds")
        }
        
        let isCorrect = viewModel.checkMnemonic(mnemonic)
        
        if isCorrect {
            passphraseVerifyView.setWrongChoiceLabel(hidden: true)
            cell.contextView.setMode(.correct)
            
            if viewModel.currentIndex == viewModel.numberOfValidations - 1 {
                let configurator = BottomInformationViewConfigurator(
                    title: "pass-phrase-verify-pop-up-title".localized,
                    image: img("img-green-checkmark"),
                    explanation: "pass-phrase-verify-pop-up-explanation".localized,
                    actionTitle: "title-accept".localized,
                    actionImage: img("bg-main-button")) {
                        self.open(.accountNameSetup, by: .push)
                }
                
                open(
                    .bottomInformation(mode: .confirmation, configurator: configurator),
                    by: .customPresentWithoutNavigationController(
                        presentationStyle: .custom,
                        transitionStyle: nil,
                        transitioningDelegate: bottomModalPresenter
                    )
                )
                
                cell.contextView.setMode(.idle)
                return
            } else {
                viewModel.incrementCurrentIndex()
                updatePassPhraseLabel()
            }
        } else {
            passphraseVerifyView.setWrongChoiceLabel(hidden: false)
            cell.contextView.setMode(.wrong)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            cell.contextView.setMode(.idle)
        }
    }
}

extension PassphraseVerifyViewController: LeftAlignedCollectionViewFlowLayoutDelegate {
    func leftAlignedLayout(_ layout: LeftAlignedCollectionViewFlowLayout, sizeFor indexPath: IndexPath) -> CGSize {
        guard let mnemonic = passphraseViewModel?.mnemonic(atIndex: indexPath.item) else {
            fatalError("Index path is out of bounds")
        }
        
        return CGSize(width: mnemonic.width(usingFont: UIFont.font(withWeight: .medium(size: 14.0))) + 50.0, height: 48.0)
    }
    
    func leftAlignedLayoutDidCalculateHeight(_ height: CGFloat) {
        passphraseVerifyView.passphraseCollectionView.snp.updateConstraints { maker in
            maker.height.greaterThanOrEqualTo(height)
        }
    }
}
