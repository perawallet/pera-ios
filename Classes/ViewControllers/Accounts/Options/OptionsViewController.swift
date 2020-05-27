//
//  OptionsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 27.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class OptionsViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var optionsView = OptionsView()
    
    private let viewModel = OptionsViewModel()
    private var account: Account
    
    weak var delegate: OptionsViewControllerDelegate?
    
    private var options: [Options]
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        
        if let accountInformation = configuration.session?.accountInformation(from: account.address) {
            if account.isThereAnyDifferentAsset() {
                options = Options.allOptions
            } else {
                options = Options.optionsWithoutRemoveAsset
            }
            
            if accountInformation.type == .ledger {
                options.removeAll { option -> Bool in
                    option == .passphrase
                }
            }
        } else {
            options = Options.allOptions
        }
        
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = SharedColors.secondaryBackground
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
    func optionsViewDidTapCancelButton(_ optionsView: OptionsView) {
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
        case .removeAsset:
            delegate?.optionsViewControllerDidRemoveAsset(self)
        case .passphrase:
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
        case passphrase = 0
        case edit = 1
        case removeAsset = 2
        case removeAccount = 3
        
        static var optionsWithoutRemoveAsset: [Options] {
            return [.edit, .removeAccount]
        }

        static var optionsWithoutPassphrase: [Options] {
            return [.edit, .removeAsset, .removeAccount]
        }
        
        static var optionsWithoutPassphraseAndRemoveAsset: [Options] {
            return [.edit, .removeAccount]
        }
        
        static var allOptions: [Options] {
            return [.passphrase, .edit, .removeAsset, .removeAccount]
        }
    }
}

extension OptionsViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let cellHeight: CGFloat = 48.0
    }
}

protocol OptionsViewControllerDelegate: class {
    func optionsViewControllerDidRemoveAsset(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidViewPassphrase(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidEditAccountName(_ optionsViewController: OptionsViewController)
    func optionsViewControllerDidRemoveAccount(_ optionsViewController: OptionsViewController)
}
