//
//  PassPhraseVerifyViewController.swift
//  algorand
//
//  Created by Omer Emre Aslan on 25.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassPhraseVerifyViewController: BaseScrollViewController {
    
    private lazy var passPhraseViewModel: PassPhraseViewModel? = {
        if let privateKey = session?.privateData(for: "temp") {
            return PassPhraseViewModel(privateKey: privateKey)
        }
        return nil
    }()
    
    private(set) lazy var passPhraseVerifyView = PassPhraseVerifyView()
    
    private(set) lazy var collectionView: UICollectionView = {
        let collectionViewLayout = LeftAlignedCollectionViewFlowLayout()
        collectionViewLayout.delegate = self
        collectionViewLayout.minimumLineSpacing = 8.0
        collectionViewLayout.minimumInteritemSpacing = 8.0
        collectionViewLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: collectionViewLayout)
        collectionView.register(
            PassPhraseCollectionViewCell.self,
            forCellWithReuseIdentifier: PassPhraseCollectionViewCell.reusableIdentifier
        )
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var tryAgainLabel: UILabel = {
        let label = UILabel()
            .withText("pass-phrase-verify-try-again".localized)
            .withTextColor(Colors.tryAgainLabelColor)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 13.0)))
            .withAlignment(.center)
        label.isHidden = true
        return label
    }()
    
    override func configureAppearance() {
        super.configureAppearance()
        view.backgroundColor = Colors.backgroundColor
        updatePassPhraseLabel()
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupPassphraseViewLayout()
        setupCollectionViewLayout()
        setupTryAgainLabelLayout()
    }
}

extension PassPhraseVerifyViewController {
    private func setupPassphraseViewLayout() {
        contentView.addSubview(passPhraseVerifyView)
        
        passPhraseVerifyView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
    
    private func setupCollectionViewLayout() {
        contentView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(passPhraseVerifyView.snp.bottom).offset(60)
            make.leading.trailing.equalToSuperview().inset(25)
            make.height.greaterThanOrEqualTo(200)
        }
    }
    
    private func setupTryAgainLabelLayout() {
        contentView.addSubview(tryAgainLabel)
        
        tryAgainLabel.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(20.0 + view.safeAreaBottom)
        }
    }
}

extension PassPhraseVerifyViewController {
    private func updatePassPhraseLabel() {
        let currentIndex = passPhraseViewModel?.currentIndex.advanced(by: 1) ?? 1
        let currentIndexValue = passPhraseViewModel?.currentIndexValue().advanced(by: 1) ?? 0
        
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
        
        let titleText = "Question \(currentIndex) of \(passPhraseViewModel?.numberOfValidations ?? 0): ".localized
        let subtitleText = "Select the \(currentIndexString) word of your passphrase".localized
        
        passPhraseVerifyView.questionTitleLabel.text = titleText
        passPhraseVerifyView.questionSubtitleLabel.text = subtitleText
    }
}

extension PassPhraseVerifyViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return passPhraseViewModel?.numberOfMnemonic() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let mnemonic = passPhraseViewModel?.mnemonic(atIndex: indexPath.item),
            let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PassPhraseCollectionViewCell.reusableIdentifier,
            for: indexPath) as? PassPhraseCollectionViewCell else {
                fatalError("Index path is out of bounds")
        }
        
        cell.contextView.phraseLabel.text = mnemonic
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = passPhraseViewModel,
            let mnemonic = viewModel.mnemonic(atIndex: indexPath.item),
            let cell = collectionView.cellForItem(at: indexPath) as? PassPhraseCollectionViewCell else {
                fatalError("Index path is out of bounds")
        }
        
        let isCorrect = viewModel.checkMnemonic(mnemonic)
        
        if isCorrect {
            tryAgainLabel.isHidden = true
            cell.contextView.setMode(.correct)
            
            if viewModel.currentIndex == viewModel.numberOfValidations - 1 {
                let configurator = AlertViewConfigurator(
                    title: "pass-phrase-verify-pop-up-title".localized,
                    image: img("password-alert-icon"),
                    explanation: "pass-phrase-verify-pop-up-explanation".localized,
                    actionTitle: nil) {
                        self.open(.accountNameSetup, by: .push)
                }
                
                open(
                    .alert(mode: .default, alertConfigurator: configurator),
                    by: .customPresentWithoutNavigationController(
                        presentationStyle: .overCurrentContext,
                        transitionStyle: .crossDissolve,
                        transitioningDelegate: nil
                    )
                )
                
                cell.contextView.setMode(.idle)
                return
            } else {
                viewModel.incrementCurrentIndex()
                updatePassPhraseLabel()
            }
        } else {
            tryAgainLabel.isHidden = false
            cell.contextView.setMode(.wrong)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            cell.contextView.setMode(.idle)
        }
    }
}

extension PassPhraseVerifyViewController: LeftAlignedCollectionViewFlowLayoutDelegate {
    func leftAlignedLayout(_ layout: LeftAlignedCollectionViewFlowLayout, sizeFor indexPath: IndexPath) -> CGSize {
        guard let mnemonic = passPhraseViewModel?.mnemonic(atIndex: indexPath.item) else {
            fatalError("Index path is out of bounds")
        }
        
        return CGSize(width: mnemonic.width(usingFont: PassPhraseMnemonicView.Font.phraseLabel) + 50.0, height: 44.0)
    }
    
    func leftAlignedLayoutDidCalculateHeight(_ height: CGFloat) {
        collectionView.snp.updateConstraints { maker in
            maker.height.greaterThanOrEqualTo(height)
        }
    }
}

extension PassPhraseVerifyViewController {
    private enum Colors {
        static let backgroundColor = rgb(0.97, 0.97, 0.98)
        static let tryAgainLabelColor = rgb(0.67, 0.67, 0.72)
    }
}
