//
//  RekeyInstructionsViewController.swift

import UIKit

class RekeyInstructionsViewController: BaseScrollViewController {
    
    private lazy var rekeyInstructionsView = RekeyInstructionsView()
    
    private let account: Account
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        if account.requiresLedgerConnection() {
            rekeyInstructionsView.setSubtitleText("rekey-instruction-subtitle-ledger".localized)
            rekeyInstructionsView.setSecondInstructionViewTitle("rekey-instruction-second-ledger".localized)
        } else {
            rekeyInstructionsView.setSubtitleText("rekey-instruction-subtitle-standard".localized)
            rekeyInstructionsView.setSecondInstructionViewTitle("rekey-instruction-second-standard".localized)
        }
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        rekeyInstructionsView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupRekeyInstructionsViewLayout()
    }
}

extension RekeyInstructionsViewController {
    private func setupRekeyInstructionsViewLayout() {
        contentView.addSubview(rekeyInstructionsView)
        
        rekeyInstructionsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension RekeyInstructionsViewController: RekeyInstructionsViewDelegate {
    func rekeyInstructionsViewDidStartRekeying(_ rekeyInstructionsView: RekeyInstructionsView) {
        open(.ledgerDeviceList(flow: .addNewAccount(mode: .rekey(account: account))), by: .push)
    }
}
