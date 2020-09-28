//
//  DeveloperSettingsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 10.09.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class DeveloperSettingsViewController: BaseViewController {
    
    private var settings: [DeveloperSettings] = [.nodeSettings]
    
    private lazy var developerSettingsView = DeveloperSettingsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let isTestNet = api?.isTestNet,
            isTestNet {
            settings.append(.dispenser)
            developerSettingsView.collectionView.reloadData()
        }
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "settings-developer".localized
    }
    
    override func linkInteractors() {
        developerSettingsView.collectionView.delegate = self
        developerSettingsView.collectionView.dataSource = self
    }
    
    override func prepareLayout() {
        setupDeveloperSettingsViewLayout()
    }
}

extension DeveloperSettingsViewController {
    private func setupDeveloperSettingsViewLayout() {
        view.addSubview(developerSettingsView)
        
        developerSettingsView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.safeEqualToTop(of: self)
            make.bottom.safeEqualToBottom(of: self)
        }
    }
}

extension DeveloperSettingsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SettingsDetailCell.reusableIdentifier,
            for: indexPath
        ) as? SettingsDetailCell,
            let setting = settings[safe: indexPath.item] else {
                fatalError("Index path is out of bounds")
        }
        
        SettingsDetailViewModel(setting: setting).configure(cell)
        return cell
    }
}

extension DeveloperSettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 72.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let setting = settings[safe: indexPath.item] else {
            fatalError("Index path is out of bounds")
        }
        
        switch setting {
        case .nodeSettings:
            open(.nodeSettings, by: .push)
        case .dispenser:
            guard let url = URL(string: "https://bank.testnet.algorand.network") else {
                return
            }
            
            open(url)
        }
    }
}
