//
//  LedgerDeviceListViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerDeviceListViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()

    private lazy var ledgerDeviceListView = LedgerDeviceListView()
    
    private let viewModel = LedgerDeviceListViewModel()
    
    private var ledgerDevices = ["Kaan's Ledger", "Hipo Ledger"]
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "ledger-device-list-title".localized
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        ledgerDeviceListView.delegate = self
        ledgerDeviceListView.devicesCollectionView.delegate = self
        ledgerDeviceListView.devicesCollectionView.dataSource = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupLedgerDeviceListViewLayout()
    }
}

extension LedgerDeviceListViewController {
    private func setupLedgerDeviceListViewLayout() {
        view.addSubview(ledgerDeviceListView)
        
        ledgerDeviceListView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension LedgerDeviceListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ledgerDevices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LedgerDeviceCell.reusableIdentifier,
            for: indexPath) as? LedgerDeviceCell else {
                fatalError("Index path is out of bounds")
        }
        
        let deviceName = ledgerDevices[indexPath.item]
        viewModel.configure(cell, with: deviceName)
        cell.delegate = self
        return cell
    }
}

extension LedgerDeviceListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return layout.current.cellSize
    }
}

extension LedgerDeviceListViewController: LedgerDeviceCellDelegate {
    func ledgerDeviceCellDidTapConnectButton(_ ledgerDeviceCell: LedgerDeviceCell) {
        guard let indexPath = ledgerDeviceListView.devicesCollectionView.indexPath(for: ledgerDeviceCell) else {
            return
        }
        
        let ledgerDevice = ledgerDevices[indexPath.item]
        open(.ledgerPairing(address: ledgerDevice), by: .push)
    }
}

extension LedgerDeviceListViewController: LedgerDeviceListViewDelegate {
    func ledgerDeviceListViewDidTapTroubleshootButton(_ ledgerDeviceListView: LedgerDeviceListView) {
        open(.ledgerTroubleshoot, by: .present)
    }
}

extension LedgerDeviceListViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let cellSize = CGSize(width: UIScreen.main.bounds.width - 36.0, height: 58.0)
    }
}
