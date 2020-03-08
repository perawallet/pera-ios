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
    
    private var receivedDataCount = 0
    
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
        open(.ledgerTroubleshoot, by: .present)
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
        receivedDataCount += 1
        ledgerBLEController.updateIncomingData(with: string)
    }
    
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didFailBLEConnectionWith state: CBManagerState) {
        connectedDevice = nil
        
        switch state {
        case .poweredOff:
            pushNotificationController.showFeedbackMessage("ble-error-fail-ble-connection-power".localized, subtitle: "")
        case .unsupported:
            pushNotificationController.showFeedbackMessage("ble-error-fail-ble-connection-unsupported".localized, subtitle: "")
        case .unknown:
            pushNotificationController.showFeedbackMessage("ble-error-fail-ble-connection-unknown".localized, subtitle: "")
        case .unauthorized:
            pushNotificationController.showFeedbackMessage("ble-error-fail-ble-connection-unauthorized".localized, subtitle: "")
        case .resetting:
            pushNotificationController.showFeedbackMessage("ble-error-fail-ble-connection-resetting".localized, subtitle: "")
        default:
            return
        }
    }
    
    func bleConnectionManager(
        _ bleConnectionManager: BLEConnectionManager,
        didDisconnectFrom peripheral: CBPeripheral,
        with error: BLEError?
    ) {
        connectedDevice = nil
        ledgerApprovalViewController.removeFromParentController()
        pushNotificationController.showFeedbackMessage("ble-error-disconnected-peripheral".localized, subtitle: "")
    }
    
    func bleConnectionManager(
        _ bleConnectionManager: BLEConnectionManager,
        didFailToConnect peripheral: CBPeripheral,
        with error: BLEError?
    ) {
        connectedDevice = nil
        ledgerApprovalViewController.removeFromParentController()
        pushNotificationController.showFeedbackMessage("ble-error-fail-connect-peripheral".localized, subtitle: "")
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
        
        // swiftlint:disable todo
        // TODO: This is a temp fix for a bug related to received data count from the ledger device.
        // The data somehow comes twice from the ledger device.
        // This issue should be tested on other devices and fixed in some other way.
        // swiftlint:enable todo
        if receivedDataCount == 1 {
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
            pushNotificationController.showFeedbackMessage("ble-error-fail-fetch-account-address".localized, subtitle: "")
            return
        }

        if error != nil {
            connectedDevice = nil
            pushNotificationController.showFeedbackMessage("ble-error-fail-fetch-account-address".localized, subtitle: "")
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
