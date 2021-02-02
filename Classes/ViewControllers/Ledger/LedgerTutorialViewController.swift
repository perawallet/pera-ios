//
//  LedgerTutorialViewController.swift

import UIKit

class LedgerTutorialViewController: BaseScrollViewController {
    
    private lazy var ledgerTutorialView = LedgerTutorialView()
    
    private let accountSetupFlow: AccountSetupFlow
    
    init(accountSetupFlow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.accountSetupFlow = accountSetupFlow
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "ledger-pair-title".localized
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        ledgerTutorialView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupLedgerTutorialViewLayout()
    }
}

extension LedgerTutorialViewController {
    private func setupLedgerTutorialViewLayout() {
        contentView.addSubview(ledgerTutorialView)
        
        ledgerTutorialView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension LedgerTutorialViewController: LedgerTutorialViewDelegate {
    func ledgerTutorialViewDidTapSearchButton(_ ledgerTutorialView: LedgerTutorialView) {
        open(.ledgerDeviceList(flow: accountSetupFlow), by: .push)
    }
    
    func ledgerTutorialView(_ ledgerTutorialView: LedgerTutorialView, didTap section: LedgerTutorialSection) {
        switch section {
        case .ledgerBluetoothConnection:
            open(.ledgerTroubleshootLedgerConnection, by: .present)
        case .installApp:
            open(.ledgerTroubleshootInstallApp, by: .present)
        case .openApp:
            open(.ledgerTroubleshootOpenApp, by: .present)
        case .bluetoothConnection:
            open(.ledgerTroubleshootBluetooth, by: .present)
        }
    }
}
