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
    
    private lazy var ledgerApprovalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 354.0))
    )
    
    private var ledgerApprovalViewController: LedgerApprovalViewController?
    
    private let mode: AccountSetupMode
    private var ledgerDevices = [CBPeripheral]()
    private var connectedDevice: CBPeripheral?
    
    init(mode: AccountSetupMode, configuration: ViewControllerConfiguration) {
        self.mode = mode
        super.init(configuration: configuration)
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
        ledgerDeviceListView.invalidateContentSize(by: ledgerDevices.count)
        ledgerDeviceListView.devicesCollectionView.reloadData()
    }
    
    func bleConnectionManager(_ bleConnectionManager: BLEConnectionManager, didConnect peripheral: CBPeripheral) {
        connectedDevice = peripheral
        ledgerApprovalViewController = open(
            .ledgerApproval(mode: .connection),
            by: .customPresent(presentationStyle: .custom, transitionStyle: nil, transitioningDelegate: ledgerApprovalPresenter)
        ) as? LedgerApprovalViewController
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
        
        guard let errorTitle = state.errorDescription.title,
            let errorSubtitle = state.errorDescription.subtitle else {
                return
        }
        
        NotificationBanner.showError(errorTitle, message: errorSubtitle)
    }
    
    func bleConnectionManager(
        _ bleConnectionManager: BLEConnectionManager,
        didDisconnectFrom peripheral: CBPeripheral,
        with error: BLEError?
    ) {
        connectedDevice = nil
        ledgerApprovalViewController?.dismissScreen()
        NotificationBanner.showError("ble-error-connection-title".localized, message: "ble-error-fail-connect-peripheral".localized)
    }
    
    func bleConnectionManager(
        _ bleConnectionManager: BLEConnectionManager,
        didFailToConnect peripheral: CBPeripheral,
        with error: BLEError?
    ) {
        connectedDevice = nil
        ledgerApprovalViewController?.dismissScreen()
        NotificationBanner.showError("ble-error-connection-title".localized, message: "ble-error-fail-connect-peripheral".localized)
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
        
        if data.toHexString() == ledgerErrorResponse {
            ledgerApprovalViewController?.dismissScreen()
            connectedDevice = nil
            NotificationBanner.showError(
                "ble-error-ledger-connection-title".localized,
                message: "ble-error-ledger-connection-open-app-error".localized
            )
            return
        }
        
        // Remove last two bytes to fetch data
        var mutableData = data
        mutableData.removeLast(2)

        var error: NSError?
        let address = AlgorandSDK().addressFromPublicKey(mutableData, error: &error)
        
        if !AlgorandSDK().isValidAddress(address) {
            ledgerApprovalViewController?.dismissScreen()
            connectedDevice = nil
            NotificationBanner.showError(
                "ble-error-transmission-title".localized,
                message: "ble-error-fail-fetch-account-address".localized
            )
            return
        }

        if error != nil {
            ledgerApprovalViewController?.dismissScreen()
            connectedDevice = nil
            NotificationBanner.showError(
                "ble-error-transmission-title".localized,
                message: "ble-error-fail-fetch-account-address".localized
            )
            return
        }
        
        if session?.account(from: address) != nil {
            ledgerApprovalViewController?.dismissScreen()
            connectedDevice = nil
            NotificationBanner.showError("title-error.localized".localized, message: "recover-from-seed-verify-exist-error".localized)
            return
        }
        
        if let connectedDeviceId = connectedDevice?.identifier {
            ledgerApprovalViewController?.closeScreen(by: .dismiss, animated: true) {
                switch self.mode {
                case let .rekey(account):
                    let ledgerDetail = LedgerDetail(id: connectedDeviceId, name: self.connectedDevice?.name, address: address)
                    self.open(.rekeyConfirmation(account: account, ledger: ledgerDetail), by: .push)
                default:
                    self.open(.ledgerPairing(mode: self.mode, address: address, connectedDeviceId: connectedDeviceId), by: .push)
                }
            }
        }
    }
}

extension LedgerDeviceListViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let cellSize = CGSize(width: UIScreen.main.bounds.width - 28.0, height: 60.0)
    }
}
