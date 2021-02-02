//
//  LedgerAccountDetailViewController.swift

import UIKit
import SVProgressHUD

class LedgerAccountDetailViewController: BaseScrollViewController {
    
    private lazy var ledgerAccountDetailView = LedgerAccountDetailView()

    private lazy var dataSource: LedgerAccountDetailViewDataSource = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return LedgerAccountDetailViewDataSource(api: api)
    }()

    private let account: Account
    private let ledgerIndex: Int?
    private let rekeyedAccounts: [Account]?
    
    init(account: Account, ledgerIndex: Int?, rekeyedAccounts: [Account]?, configuration: ViewControllerConfiguration) {
        self.account = account
        self.ledgerIndex = ledgerIndex
        self.rekeyedAccounts = rekeyedAccounts
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.fetchAssets(for: account)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        if let index = ledgerIndex {
            title = "Ledger #\(index)"
        } else {
            title = account.address.shortAddressDisplay()
        }
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupLedgerAccountDetailViewLayout()
    }

    override func linkInteractors() {
        super.linkInteractors()
        dataSource.delegate = self
    }
}

extension LedgerAccountDetailViewController {
    private func setupLedgerAccountDetailViewLayout() {
        contentView.addSubview(ledgerAccountDetailView)
        
        ledgerAccountDetailView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension LedgerAccountDetailViewController: LedgerAccountDetailViewDataSourceDelegate {
    func ledgerAccountDetailViewDataSource(
        _ ledgerAccountDetailViewDataSource: LedgerAccountDetailViewDataSource,
        didReturn account: Account
    ) {
        ledgerAccountDetailView.bind(LedgerAccountDetailViewModel(account: account, rekeyedAccounts: rekeyedAccounts))
    }
}
