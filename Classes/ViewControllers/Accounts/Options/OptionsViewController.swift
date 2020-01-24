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
    func optionsViewControllerDidRemoveAsset(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidViewPassphrase(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidEditAccountName(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidRemoveAccount(_ optionsViewController: OptionsViewController)
}

class OptionsViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var optionsView = OptionsView()
    
    private let viewModel = OptionsViewModel()
    private var account: Account
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    weak var delegate: OptionsViewControllerDelegate?
    
    private var options: [Options]
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        
        if account.isThereAnyDifferentAsset() {
            options = Options.allOptions
        } else {
            options = Options.optionsWithoutRemoveAsset
        }
        
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = .white
    }
    
    override func linkInteractors() {
        optionsView.optionsCollectionView.delegate = self
        optionsView.delegate = self
        optionsView.optionsCollectionView.dataSource = self
    }
    
    override func prepareLayout() {
        setupOptionsViewLayout()
    }
}

extension OptionsViewController {
    private func setupOptionsViewLayout() {
        view.addSubview(optionsView)
        
        optionsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension OptionsViewController: OptionsViewDelegate {
    func optionsViewDidTapDismissButton(_ optionsView: OptionsView) {
        dismissScreen()
    }
}

extension OptionsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OptionsCell.reusableIdentifier,
            for: indexPath) as? OptionsCell else {
                fatalError("Index path is out of bounds")
        }
        
        let option = options[indexPath.item]
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
        let selectedOption = options[indexPath.item]
        
        dismissScreen()
        
        switch selectedOption {
        case .showQR:
            delegate?.optionsViewControllerDidShowQR(self)
        case .removeAsset:
            delegate?.optionsViewControllerDidRemoveAsset(self)
        case .passPhrase:
            delegate?.optionsViewControllerDidViewPassphrase(self)
        case .edit:
            delegate?.optionsViewControllerDidEditAccountName(self)
        case .removeAccount:
            delegate?.optionsViewControllerDidRemoveAccount(self)
        }
    }
}

extension OptionsViewController {
    enum Options: Int, CaseIterable {
        case showQR = 0
        case removeAsset = 1
        case passPhrase = 2
        case edit = 3
        case removeAccount = 4
        
        static var optionsWithoutRemoveAsset: [Options] {
            return [.showQR, passPhrase, .edit, .removeAccount]
        }
        
        static var allOptions: [Options] {
            return [.showQR, .removeAsset, passPhrase, .edit, .removeAccount]
        }
    }
}

extension OptionsViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let cellHeight: CGFloat = 56.0
    }
}
