//
//  LanguageSelectionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 7.10.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LanguageSelectionViewController: BaseViewController {
    
    private lazy var languageSelectionView = SingleSelectionListView()
    
    weak var delegate: LanguageSelectionViewControllerDelegate?
    
    private var languages = [Language]()
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "settings-language".localized
    }
    
    override func linkInteractors() {
        languageSelectionView.delegate = self
        languageSelectionView.setDataSource(self)
        languageSelectionView.setListDelegate(self)
    }
    
    override func prepareLayout() {
        setupLanguageSelectionViewLayout()
    }
}

extension LanguageSelectionViewController {
    private func setupLanguageSelectionViewLayout() {
        view.addSubview(languageSelectionView)
        
        languageSelectionView.snp.makeConstraints { make in
            make.top.safeEqualToTop(of: self)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension LanguageSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedLanguage = languages[safe: indexPath.item] else {
            return
        }
        
        //LanguageChangeEvent(languageId: selectedLanguage.id).logEvent()
        languageSelectionView.reloadData()
        delegate?.languageSelectionViewControllerDidSelectLanguage(self)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 72.0)
    }
}

extension LanguageSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return languages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let language = languages[safe: indexPath.item],
           let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SingleSelectionCell.reusableIdentifier,
                for: indexPath
            ) as? SingleSelectionCell {
                let isSelected = false
                cell.contextView.bind(SingleSelectionViewModel(title: language.name, isSelected: isSelected))
                return cell
        }
        
        fatalError("Index path is out of bounds")
    }
}

extension LanguageSelectionViewController: SingleSelectionListViewDelegate {
    func singleSelectionListViewDidRefreshList(_ singleSelectionListView: SingleSelectionListView) {
        singleSelectionListView.reloadData()
    }
    
    func singleSelectionListViewDidTryAgain(_ singleSelectionListView: SingleSelectionListView) {
        singleSelectionListView.reloadData()
    }
}

protocol LanguageSelectionViewControllerDelegate: class {
    func languageSelectionViewControllerDidSelectLanguage(_ languageSelectionViewController: LanguageSelectionViewController)
}
