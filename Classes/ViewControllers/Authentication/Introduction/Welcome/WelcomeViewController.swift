//
//  WelcomeViewController.swift

import UIKit

class WelcomeViewController: BaseViewController {

    private lazy var welcomeView = WelcomeView()

    private let flow: AccountSetupFlow

    init(flow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.flow = flow
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }

        switch flow {
        case .addNewAccount:
            leftBarButtonItems = [closeBarButtonItem]
        case .initializeAccount:
            break
        }
    }

    override func configureAppearance() {
        view.backgroundColor = Colors.Background.tertiary
        setTertiaryBackgroundColor()
        welcomeView.configureAddAccountView(with: AccountTypeViewModel(accountSetupMode: .add))
        welcomeView.configureRecoverAccountView(with: AccountTypeViewModel(accountSetupMode: .recover))
    }

    override func linkInteractors() {
        welcomeView.delegate = self
    }

    override func prepareLayout() {
        prepareWholeScreenLayoutFor(welcomeView)
    }
}

extension WelcomeViewController: WelcomeViewDelegate {
    func welcomeView(_ welcomeView: WelcomeView, didSelect mode: AccountSetupMode) {
        switch flow {
        case .initializeAccount:
            open(.choosePassword(mode: .setup, flow: .initializeAccount(mode: mode), route: nil), by: .push)
        case .addNewAccount:
            switch mode {
            case .add:
                open(.addAccount(flow: flow), by: .push)
            case .recover:
                open(.accountRecover(flow: .addNewAccount(mode: .recover)), by: .push)
            case .create,
                 .pair,
                 .transfer,
                 .rekey,
                 .watch:
                    break
            }
        }
    }

    func welcomeView(_ welcomeView: WelcomeView, didOpen url: URL) {
        open(url)
    }
}
