// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  LedgerDeviceListViewController.swift

import UIKit
import CoreBluetooth

final class LedgerDeviceListViewController: BaseViewController {
    private lazy var ledgerDeviceListView = LedgerDeviceListView()
    private lazy var theme = Theme()
    
    private lazy var ledgerAccountFetchOperation: LedgerAccountFetchOperation = {
        guard let api = api else {
            fatalError("Api must be set before accessing this view controller.")
        }
        return LedgerAccountFetchOperation(api: api, bannerController: bannerController)
    }()
    
    private let accountSetupFlow: AccountSetupFlow
    private var ledgerDevices = [CBPeripheral]()

    init(accountSetupFlow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.accountSetupFlow = accountSetupFlow
        super.init(configuration: configuration)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ledgerDeviceListView.startAnimatingImageView()
        ledgerDeviceListView.startAnimatingIndicatorView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ledgerAccountFetchOperation.reset()
        ledgerDeviceListView.stopAnimatingImageView()
        ledgerDeviceListView.stopAnimatingIndicatorView()
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        ledgerAccountFetchOperation.delegate = self
        ledgerDeviceListView.devicesCollectionView.delegate = self
        ledgerDeviceListView.devicesCollectionView.dataSource = self
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: AppColors.Shared.System.background)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        view.addSubview(ledgerDeviceListView)
        ledgerDeviceListView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
        
        let device = ledgerDevices[indexPath.item]
        cell.customize(LedgerDeviceCellViewTheme())
        cell.bindData(LedgerDeviceListViewModel(device))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ledgerAccountFetchOperation.connectToDevice(ledgerDevices[indexPath.item])
    }
}

extension LedgerDeviceListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(theme.cellSize)
    }
}

extension LedgerDeviceListViewController: LedgerAccountFetchOperationDelegate {
    func ledgerAccountFetchOperation(
        _ ledgerAccountFetchOperation: LedgerAccountFetchOperation,
        didReceive accounts: [Account],
        in ledgerApprovalViewController: LedgerApprovalViewController?
    ) {
        ledgerDeviceListView.stopAnimatingIndicatorView()

        if isViewDisappearing {
            return
        }
        
        ledgerApprovalViewController?.closeScreen(by: .dismiss, animated: true) {
            self.open(.ledgerAccountSelection(flow: self.accountSetupFlow, accounts: accounts), by: .push)
        }
    }
    
    func ledgerAccountFetchOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation, didDiscover peripherals: [CBPeripheral]) {
        ledgerDeviceListView.stopAnimatingIndicatorView()
        ledgerDevices = peripherals
        ledgerDeviceListView.devicesCollectionView.reloadData()
    }
    
    func ledgerAccountFetchOperation(_ ledgerAccountFetchOperation: LedgerAccountFetchOperation, didFailed error: LedgerOperationError) {
        ledgerDeviceListView.stopAnimatingIndicatorView()
        switch error {
        case .cancelled:
            bannerController?.presentErrorBanner(
                title: "ble-error-transaction-cancelled-title".localized,
                message: "ble-error-fail-sign-transaction".localized
            )
        case .closedApp:
            bannerController?.presentErrorBanner(
                title: "ble-error-ledger-connection-title".localized,
                message: "ble-error-ledger-connection-open-app-error".localized
            )
        default:
            break
        }
    }
}
