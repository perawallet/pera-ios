//
//  PassPhraseVerifyViewController.swift
//  algorand
//
//  Created by Omer Emre Aslan on 25.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import Crypto

class PassPhraseVerifyViewController: BaseScrollViewController {
    
    fileprivate lazy var passPhraseViewModel: PassPhraseViewModel? = {
        if let privateKey = session?.privateData(forAccount: "temp") {
            return PassPhraseViewModel(privateKey: privateKey)
        }
        
        return nil
    }()
    
    fileprivate private(set) lazy var passPhraseVerifyView: PassPhraseVerifyView = {
        let passPhraseVerifyView = PassPhraseVerifyView()
        return passPhraseVerifyView
    }()
    
    fileprivate private(set) lazy var collectionView: UICollectionView = {
        let collectionViewLayout = LeftAlignedCollectionViewFlowLayout()
        collectionViewLayout.delegate = self
        collectionViewLayout.minimumLineSpacing = 8.0
        collectionViewLayout.minimumInteritemSpacing = 8.0
        collectionViewLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: collectionViewLayout)
        collectionView.register(PassPhraseCollectionViewCell.self,
                                forCellWithReuseIdentifier: PassPhraseCollectionViewCell.reusableIdentifier)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePassPhraseLabel()
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupLayout()
    }
    
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

// MARK: - Layout
extension PassPhraseVerifyViewController {
    fileprivate func setupLayout() {
        view.backgroundColor = rgb(0.97, 0.97, 0.98)
        
        contentView.addSubview(passPhraseVerifyView)
        passPhraseVerifyView.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview()
            maker.top.equalToSuperview()
            maker.height.equalTo(200)
        }
        
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { maker in
            maker.top.equalTo(passPhraseVerifyView.snp.bottom).offset(15)
            maker.leading.trailing.equalToSuperview().inset(25)
            maker.height.greaterThanOrEqualTo(200)
            maker.bottom.equalToSuperview().inset(view.safeAreaBottom).priority(.high)
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PassPhraseVerifyViewController: UICollectionViewDelegate,
UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return passPhraseViewModel?.numberOfMnemonic() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let mnemonic = passPhraseViewModel?.mnemonic(atIndex: indexPath.item) else {
            fatalError("Index path is out of bounds")
        }
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PassPhraseCollectionViewCell.reusableIdentifier,
            for: indexPath) as? PassPhraseCollectionViewCell else {
            fatalError("Index path is out of bounds")
        }
        
        cell.contextView.phraseLabel.text = mnemonic
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = passPhraseViewModel,
            let mnemonic = viewModel.mnemonic(atIndex: indexPath.item) else {
            fatalError("Index path is out of bounds")
        }
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? PassPhraseCollectionViewCell else {
            return
        }
        
        let isCorrect = viewModel.checkMnemonic(mnemonic)
        
        if isCorrect {
            cell.contextView.setMode(.correct)
            
            if viewModel.currentIndex == viewModel.numberOfValidations - 1 {
                let configurator = AlertViewConfigurator(
                    title: "pass-phrase-verify-pop-up-title".localized,
                    image: img("password-alert-icon"),
                    explanation: "pass-phrase-verify-pop-up-explanation".localized,
                    actionTitle: nil) {
                        
                        self.open(.accountNameSetup, by: .push)
                }
                
                let viewController = AlertViewController(mode: .normal, alertConfigurator: configurator, configuration: configuration)
                viewController.modalPresentationStyle = .overCurrentContext
                viewController.modalTransitionStyle = .crossDissolve
                
                present(viewController, animated: true, completion: nil)
                
                cell.contextView.setMode(.idle)
                
                return
            } else {
                viewModel.incrementCurrentIndex()
                updatePassPhraseLabel()
            }
        } else {
            cell.contextView.setMode(.wrong)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            cell.contextView.setMode(.idle)
        }
    }
}

// MARK: - LeftAlignedCollectionViewFlowLayoutDelegate
extension PassPhraseVerifyViewController: LeftAlignedCollectionViewFlowLayoutDelegate {
    func leftAlignedLayout(_ layout: LeftAlignedCollectionViewFlowLayout,
                           sizeFor indexPath: IndexPath) -> CGSize {
        guard let mnemonic = passPhraseViewModel?.mnemonic(atIndex: indexPath.item) else {
            fatalError("Index path is out of bounds")
        }
        
        let width = mnemonic.width(usingFont: PassPhraseMnemonicView.Font.phraseLabel) + 50.0
        
        return CGSize(width: width, height: 44.0)
    }
    
    func leftAlignedLayoutDidCalculateHeight(_ height: CGFloat) {
        self.collectionView.snp.updateConstraints { maker in
            maker.height.greaterThanOrEqualTo(height)
        }
    }
}
