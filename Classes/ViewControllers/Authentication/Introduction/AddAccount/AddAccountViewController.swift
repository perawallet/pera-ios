//
//  AddAccountViewController.swift

import UIKit

class AddAccountViewController: BaseViewController {
    
    private lazy var addAccountView = AddAccountView()
    
    private let flow: AccountSetupFlow
    
    init(flow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.flow = flow
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.tertiary
        setTertiaryBackgroundColor()
        addAccountView.configureCreateNewAccountView(with: AccountTypeViewModel(accountSetupMode: .create))
        addAccountView.configureWatchAccountView(with: AccountTypeViewModel(accountSetupMode: .watch))
        addAccountView.configurePairAccountView(with: AccountTypeViewModel(accountSetupMode: .pair))
    }
    
    override func linkInteractors() {
        addAccountView.delegate = self
    }
    
    override func prepareLayout() {
        prepareWholeScreenLayoutFor(addAccountView)
    }
}

extension AddAccountViewController: AddAccountViewDelegate {
    func addAccountView(_ addAccountView: AddAccountView, didSelect mode: AccountSetupMode) {
        switch flow {
        case .initializeAccount:
            open(.choosePassword(mode: .setup, flow: .initializeAccount(mode: mode), route: nil), by: .push)
        case .addNewAccount:
            switch mode {
            case .create:
                open(.passphraseView(address: "temp"), by: .push)
            case .watch:
                open(.watchAccountAddition(flow: flow), by: .push)
            case .pair:
                open(.ledgerTutorial(flow: .addNewAccount(mode: .pair)), by: .push)
            case .recover,
                 .rekey,
                 .add,
                 .transfer:
                break
            }
        }
    }
}
