//
//  LedgerTroubleshootingViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerTroubleshootingViewController: BaseViewController {
    
    private lazy var ledgerTroubleshootingView = LedgerTroubleshootingView()
    
    private let viewModel = LedgerTroubleshootingViewModel()
    
    private var troubleshootOptions = [
        LedgerTroubleshootOption(number: .closeOthers, option: "ledger-troubleshooting-close-others".localized),
        LedgerTroubleshootOption(number: .restart, option: "ledger-troubleshooting-restart".localized),
        LedgerTroubleshootOption(number: .appSupport, option: "ledger-troubleshooting-app-support".localized),
        LedgerTroubleshootOption(number: .ledgerSupport, option: "ledger-troubleshooting-ledger-support".localized)
    ]
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "ledger-troubleshooting-title".localized
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        ledgerTroubleshootingView.optionsCollectionView.delegate = self
        ledgerTroubleshootingView.optionsCollectionView.dataSource = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupLedgerTroubleshootingViewLayout()
    }
}

extension LedgerTroubleshootingViewController {
    private func setupLedgerTroubleshootingViewLayout() {
        view.addSubview(ledgerTroubleshootingView)
        
        ledgerTroubleshootingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension LedgerTroubleshootingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let troubleshootOption = troubleshootOptions[indexPath.item]
        return viewModel.sizeFor(troubleshootOption)
    }
}

extension LedgerTroubleshootingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return troubleshootOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LedgerTroubleshootingOptionCell.reusableIdentifier,
            for: indexPath) as? LedgerTroubleshootingOptionCell else {
                fatalError("Index path is out of bounds")
        }
        
        let troubleshootOption = troubleshootOptions[indexPath.item]
        viewModel.configure(cell, with: troubleshootOption)
        return cell
    }
}
