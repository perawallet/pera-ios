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
    let mnemonics = """
marble protect crawl steak lion clock camera brother find escape matter roast toast critic velvet police old inform arena enemy milk venue cereal abandon cushion
"""
    
    fileprivate private(set) lazy var passPhraseVerifyView: PassPhraseVerifyView = {
        let passPhraseVerifyView = PassPhraseVerifyView()
        passPhraseVerifyView.questionTitleLabel.text = "Question 1 of 3: ".localized
        passPhraseVerifyView.questionSubtitleLabel.text = "Select the 4th word of your passphrase".localized
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
        return mnemonics.components(separatedBy: " ").count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = mnemonics.components(separatedBy: " ")[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PassPhraseCollectionViewCell.reusableIdentifier,
            for: indexPath) as? PassPhraseCollectionViewCell else {
            fatalError("Index path is out of bounds")
        }
        
        cell.phraseLabel.text = item
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = mnemonics.components(separatedBy: " ")[indexPath.item]
        guard let cell = collectionView.cellForItem(at: indexPath) as? PassPhraseCollectionViewCell else {
            return
        }
        
        cell.mode = .correct
    }
}

// MARK: - LeftAlignedCollectionViewFlowLayoutDelegate
extension PassPhraseVerifyViewController: LeftAlignedCollectionViewFlowLayoutDelegate {
    func leftAlignedLayout(_ layout: LeftAlignedCollectionViewFlowLayout,
                           sizeFor indexPath: IndexPath) -> CGSize {
        let item = mnemonics.components(separatedBy: " ")[indexPath.item]
        
        let width = item.width(usingFont: PassPhraseCollectionViewCell.font) + 50.0
        
        return CGSize(width: width, height: 44.0)
    }
    
    func leftAlignedLayoutDidCalculateHeight(_ height: CGFloat) {
        self.collectionView.snp.updateConstraints { maker in
            maker.height.greaterThanOrEqualTo(height)
        }
    }
}
