//
//  PassPhraseVerifyViewController.swift
//  algorand
//
//  Created by Omer Emre Aslan on 25.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassPhraseVerifyViewController: BaseScrollViewController {
    fileprivate private(set) lazy var passPhraseVerifyView: PassPhraseVerifyView = {
        let passPhraseVerifyView = PassPhraseVerifyView()
        passPhraseVerifyView.questionTitleLabel.text = "Question 1 of 3: ".localized
        passPhraseVerifyView.questionSubtitleLabel.text = "Select the 4th word of your passphrase".localized
        return passPhraseVerifyView
    }()
    
    fileprivate private(set) lazy var collectionView: UICollectionView = {
        let collectionViewLayout = LeftAlignedCollectionViewFlowLayout()
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
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupLayout()
    }
}

// MARK: - Layout
extension PassPhraseVerifyViewController {
    fileprivate func setupLayout() {
        view.backgroundColor = rgb(0.97, 0.97, 0.98)
        
        contentView.addSubview(passPhraseVerifyView)
        passPhraseVerifyView.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview()
            maker.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            maker.height.equalTo(200)
        }
        
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { maker in
            maker.top.equalTo(passPhraseVerifyView.snp.bottom).offset(15)
            maker.leading.trailing.equalToSuperview().inset(25)
            maker.bottom.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PassPhraseVerifyViewController: UICollectionViewDelegate,
UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 90
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PassPhraseCollectionViewCell.reusableIdentifier,
            for: indexPath) as? PassPhraseCollectionViewCell else {
            fatalError("Index path is out of bounds")
        }
        
        cell.contextView.text = "Test"
        
        return cell
    }
    
}
