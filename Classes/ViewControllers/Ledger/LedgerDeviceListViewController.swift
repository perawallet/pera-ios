//
//  LedgerDeviceListViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit
import CoreBluetooth

class LedgerDeviceListViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()

    private lazy var ledgerDeviceListView = LedgerDeviceListView()
    
    private lazy var bleConnectionManager = BLEConnectionManager()
    private lazy var ledgerBLEController = LedgerBLEController()
    
    private let viewModel = LedgerDeviceListViewModel()
    
    private lazy var ledgerApprovalViewController = LedgerApprovalViewController(mode: .connection, configuration: configuration)
    
    private let mode: AccountSetupMode
    private var ledgerDevices = [CBPeripheral]()
    private var connectedDevice: CBPeripheral?
    
    private lazy var pushNotificationController: PushNotificationController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return PushNotificationController(api: api)
    }()
    
    init(mode: AccountSetupMode, configuration: ViewControllerConfiguration) {
        self.mode = mode
        super.init(configuration: configuration)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // swiftlint:disable todo
        // TODO: We might need to restart scanning here somehow.
        // swiftlint:enable todo
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ledgerDeviceListView.startSearchSpinner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bleConnectionManager.stopScan()
        ledgerDeviceListView.stopSearchSpinner()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "ledger-device-list-title".localized
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        ledgerDeviceListView.delegate = self
        bleConnectionManager.delegate = self
        ledgerBLEController.delegate = self
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
        
        let devices = ledgerDevices[indexPath.item]
        if let deviceName = devices.name {
            viewModel.configure(cell, with: deviceName)
        }
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
        bleConnectionManager.connectToDevice(ledgerDevice)
    }
}

extension LedgerDeviceListViewController: LedgerDeviceListViewDelegate {
    func ledgerDeviceListViewDidTapTroubleshootButton(_ ledgerDeviceListView: LedgerDeviceListView) {
        open(.ledgerTroubleshoot, by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil))
    }
}

extension LedgerDeviceListViewController: BLEConnectionManagerDelegate {
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didDiscover peripherals: [CBPeripheral]) {
        ledgerDevices = peripherals
        ledgerDeviceListView.devicesCollectionView.reloadData()
    }
    
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didConnect peripheral: CBPeripheral) {
        connectedDevice = peripheral
        add(ledgerApprovalViewController)
    }
    
    func bleConnectionManagerEnabledToWrite(_ bleConnectionManager: BLEConnectionManager) {
        guard let bleData = Data(fromHexEncodedString: bleLedgerAddressMessage) else {
            return
        }
        
        ledgerBLEController.fetchAddress(bleData)
    }
    
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didRead string: String) {
        ledgerBLEController.updateIncomingData(with: string)
    }
    
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didFailBLEConnectionWith state: CBManagerState) {
        connectedDevice = nil
        
        guard let errorTitle = state.errorTitle, let errorSubtitle = state.errorSubtitle else {
            return
        }
        
        pushNotificationController.showFeedbackMessage(errorTitle, subtitle: errorSubtitle)
    }
    
    func bleConnectionManager(
        _ bleConnectionManager: BLEConnectionManager,
        didDisconnectFrom peripheral: CBPeripheral,
        with error: BLEError?
    ) {
        connectedDevice = nil
        ledgerApprovalViewController.removeFromParentController()
    }
    
    func bleConnectionManager(
        _ bleConnectionManager: BLEConnectionManager,
        didFailToConnect peripheral: CBPeripheral,
        with error: BLEError?
    ) {
        connectedDevice = nil
        ledgerApprovalViewController.removeFromParentController()
        pushNotificationController.showFeedbackMessage("ble-error-connection-title".localized,
                                                       subtitle: "ble-error-fail-connect-peripheral".localized)
    }
}

extension LedgerDeviceListViewController: LedgerBLEControllerDelegate {
    func ledgerBLEController(_ ledgerBLEController: LedgerBLEController, shouldWrite data: Data) {
        bleConnectionManager.write(data)
    }
    
    func ledgerBLEController(_ ledgerBLEController: LedgerBLEController, received data: Data) {
        if isViewDisappearing {
            return
        }
        
        ledgerApprovalViewController.removeFromParentController()
        
        // Remove last two bytes to fetch data
        var mutableData = data
        mutableData.removeLast(2)

        var error: NSError?
        let address = AlgorandSDK().addressFromPublicKey(mutableData, error: &error)
        
        if !AlgorandSDK().isValidAddress(address) {
            connectedDevice = nil
            pushNotificationController.showFeedbackMessage("ble-error-transmission-title".localized,
                                                           subtitle: "ble-error-fail-fetch-account-address".localized)
            return
        }

        if error != nil {
            connectedDevice = nil
            pushNotificationController.showFeedbackMessage("ble-error-transmission-title".localized,
                                                           subtitle: "ble-error-fail-fetch-account-address".localized)
            return
        }
        
        if let connectedDeviceId = connectedDevice?.identifier {
            open(.ledgerPairing(mode: mode, address: address, connectedDeviceId: connectedDeviceId), by: .push)
        }
    }
}

extension LedgerDeviceListViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let cellSize = CGSize(width: UIScreen.main.bounds.width - 36.0, height: 58.0)
    }
}
