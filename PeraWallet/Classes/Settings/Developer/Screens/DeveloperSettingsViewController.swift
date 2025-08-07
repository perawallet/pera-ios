// Copyright 2022-2025 Pera Wallet, LDA

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
//  DeveloperSettingsViewController.swift

import UIKit
import MacaroonUtils

final class DeveloperSettingsViewController:
    BaseViewController,
    NotificationObserver {
    var notificationObservations: [NSObjectProtocol] = []

    private lazy var theme = Theme()
    private lazy var developerSettingsView = DeveloperSettingsView()
    
    private lazy var pushNotificationController = PushNotificationController(
        target: target,
        session: session!,
        api: api!
    )
    
    private var settings: [DeveloperSettings] = [.nodeSettings]

    deinit {
        stopObservingNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        reload()
    }

    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        navigationItem.title = String(localized: "settings-developer")
    }
    
    override func linkInteractors() {
        developerSettingsView.collectionView.delegate = self
        developerSettingsView.collectionView.dataSource = self
    }

    override func setListeners() {
        observe(notification: NodeSettingsViewController.didUpdateNetwork) {
            [weak self] _ in
            self?.reload()
        }
    }
    
    override func prepareLayout() {
        addDeveloperSettingsView()
    }
}

extension DeveloperSettingsViewController {
    private func reload() {
        switch api?.network {
        case .mainnet, .none:
            settings = [.nodeSettings, .createAlgo25Account]
        case .testnet:
            settings = [.nodeSettings, .dispenser, .createAlgo25Account]
        }

        developerSettingsView.collectionView.reloadData()
    }
}

extension DeveloperSettingsViewController {
    private func addDeveloperSettingsView() {
        view.addSubview(developerSettingsView)
        
        developerSettingsView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.safeEqualToTop(of: self)
            $0.bottom.safeEqualToBottom(of: self)
        }
    }
}

extension DeveloperSettingsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(SettingsDetailCell.self, at: indexPath)
        
        if let setting = settings[safe: indexPath.item] {
            cell.bindData(SettingsDetailViewModel(settingsItem: setting))
            return cell
        }
        
        fatalError("Index path is out of bounds")
    }
}

extension DeveloperSettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(theme.cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let setting = settings[safe: indexPath.item] else {
            fatalError("Index path is out of bounds")
        }
        
        switch setting {
        case .nodeSettings:
            openNodeSettings()
        case .dispenser:
            let authorizedAccountListFilterAlgorithm = AuthorizedAccountListFilterAlgorithm()
            let authorizedAccounts =
                sharedDataController
                    .accountCollection
                    .filter(authorizedAccountListFilterAlgorithm.getFormula)

            if authorizedAccounts.count > 1 {
                openAccountSelection()
            } else {
                openDispenser(
                    for: authorizedAccounts.first?.value,
                    from: self
                )
            }
        case .createAlgo25Account:
            guard
                let newAccount = createAccount() else {
                return
            }
            let screen = open(
                .accountNameSetup(
                    flow: .addNewAccount(mode: .addAlgo25Account),
                    mode: .addAlgo25Account,
                    accountAddress: newAccount.address
                ),
                by: .push
            ) as? AccountNameSetupViewController
            
            screen?.onAccountCreated = { [weak self] in
                guard let self else { return }
                guard let rootViewController = UIApplication.shared.rootViewController() else {
                    return
                }
                PeraUserDefaults.shouldShowNewAccountAnimation = true
                rootViewController.launch(tab: .home)
                navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    private func createAccount() -> AccountInformation? {
        generatePrivateKey()

        guard
            let tempPrivateKey = session?.privateData(for: "temp"),
            let address = session?.address(for: "temp")
        else {
            return nil
        }
        let account = AccountInformation(
            address: address,
            name: address.shortAddressDisplay,
            isWatchAccount: false,
            preferredOrder: sharedDataController.getPreferredOrderForNewAccount(),
            isBackedUp: false
        )
        session?.savePrivate(tempPrivateKey, for: address)
        session?.removePrivateData(for: "temp")
        
        if let authenticatedUser = session?.authenticatedUser {
            authenticatedUser.addAccount(account)
            pushNotificationController.sendDeviceDetails()
        } else {
            let user = User(accounts: [account])
            session?.authenticatedUser = user
        }

        return account
    }
    
    private func generatePrivateKey() {
        guard let session = session,
              let privateKey = session.generatePrivateKey() else {
            return
        }

        session.savePrivate(privateKey, for: "temp")
    }
}

extension DeveloperSettingsViewController {
    private func openNodeSettings() {
        open(
            .nodeSettings,
            by: .push
        )
    }

    private func openAccountSelection() {
        let draft = SelectAccountDraft(
            transactionAction: .receive,
            requiresAssetSelection: false,
            transactionDraft: nil,
            receiver: nil
        )
        open(
            .accountSelection(
                draft: draft,
                delegate: self
            ),
            by: .push
        )
    }

    private func openDispenser(
        for account: Account?,
        from screen: UIViewController
    ) {
        let url = makeDispenserURL(account)
        screen.open(url)
    }

    private func makeDispenserURL(_ account: Account?) -> URL? {
        let url = AlgorandWeb.dispenser.link

        guard let account else {
            return url
        }

        let params = ["account": account.address]
        return url?.appendingQueryParameters(params)
    }
}

extension DeveloperSettingsViewController: SelectAccountViewControllerDelegate {
    func selectAccountViewController(
        _ selectAccountViewController: SelectAccountViewController,
        didSelect account: Account,
        for draft: SelectAccountDraft
    ) {
        openDispenser(
            for: account,
            from: selectAccountViewController
        )
    }
}
