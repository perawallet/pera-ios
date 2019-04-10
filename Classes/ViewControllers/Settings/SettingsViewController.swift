//
//  SettingsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class SettingsViewController: BaseViewController {
    
    private lazy var settingsView: SettingsView = {
        let settingsView = SettingsView()
        return settingsView
    }()
    
    private let viewModel = SettingsViewModel()
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "settings-title".localized
        
        view.addSubview(settingsView)
        settingsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func linkInteractors() {
        settingsView.collectionView.delegate = self
        settingsView.collectionView.dataSource = self
    }
}

// MARK: UICollectionViewDataSource

extension SettingsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let mode = SettingsViewModel.SettingsCellMode(rawValue: indexPath.item) else {
            fatalError("Index path is out of bounds")
        }
        
        switch mode {
        case .serverSettings, .password:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SettingsDetailCell.reusableIdentifier,
                for: indexPath) as? SettingsDetailCell else {
                    fatalError("Index path is out of bounds")
            }
            
            viewModel.configureDetail(cell, with: mode)
            
            return cell
            
        case .localAuthentication:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SettingsDetailCell.reusableIdentifier,
                for: indexPath) as? SettingsDetailCell else {
                    fatalError("Index path is out of bounds")
            }
            
            viewModel.configureDetail(cell, with: mode)
            
            return cell
        case .language:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SettingsInfoCell.reusableIdentifier,
                for: indexPath) as? SettingsInfoCell else {
                    fatalError("Index path is out of bounds")
            }
            
            viewModel.configureInfo(cell, with: mode)
            
            return cell
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension SettingsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width, height: 90.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view.endEditing(true)
    }
}
