//
//  OptionsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol OptionsViewControllerDelegate: class {
    
    func optionsViewControllerDidShowQR(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidSetDefaultAccount(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidViewPassphrase(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidEditAccountName(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidRemoveAccount(_ optionsViewController: OptionsViewController)
}

class OptionsViewController: BaseViewController {

    private struct LayoutConstants: AdaptiveLayoutConstants {
        let imageViewTopInset: CGFloat = 10.0
        let collectionViewTopInset: CGFloat = 22.0
        let cellHeight: CGFloat = 56.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var topImageView = UIImageView(image: img("icon-modal-top"))
    
    private(set) lazy var optionsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.contentInset = .zero
        
        collectionView.register(OptionsCell.self, forCellWithReuseIdentifier: OptionsCell.reusableIdentifier)
        
        return collectionView
    }()
    
    private let viewModel = OptionsViewModel()
    
    weak var delegate: OptionsViewControllerDelegate?
    
    // MARK: Setup
    
    override func configureAppearance() {
        view.backgroundColor = .white
    }
    
    override func linkInteractors() {
        optionsCollectionView.delegate = self
        optionsCollectionView.dataSource = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTopImageViewLayout()
        setupOptionsCollectionViewLayout()
    }
    
    private func setupTopImageViewLayout() {
        view.addSubview(topImageView)
        
        topImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.imageViewTopInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupOptionsCollectionViewLayout() {
        view.addSubview(optionsCollectionView)
        
        optionsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(topImageView.snp.bottom).offset(layout.current.collectionViewTopInset)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: UICollectionViewDataSource

extension OptionsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Options.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OptionsCell.reusableIdentifier,
            for: indexPath) as? OptionsCell else {
                fatalError("Index path is out of bounds")
        }
        
        guard let option = Options(rawValue: indexPath.row) else {
            fatalError("Index path is out of bounds")
        }
        
        viewModel.configure(cell, with: option)
        
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension OptionsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        return CGSize(width: view.frame.width, height: layout.current.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedOption = Options(rawValue: indexPath.row) else {
            fatalError("Index path is out of bounds")
        }
        
        dismissScreen()
        
        switch selectedOption {
        case .showQR:
            delegate?.optionsViewControllerDidShowQR(self)
        case .setDefault:
            delegate?.optionsViewControllerDidSetDefaultAccount(self)
        case .passPhrase:
            delegate?.optionsViewControllerDidViewPassphrase(self)
        case .edit:
            delegate?.optionsViewControllerDidEditAccountName(self)
        case .remove:
            delegate?.optionsViewControllerDidRemoveAccount(self)
        }
    }
}

// MARK: Options

extension OptionsViewController {
    
    enum Options: Int, CaseIterable {
        case showQR = 0
        case setDefault = 1
        case passPhrase = 2
        case edit = 3
        case remove = 4
    }
}
