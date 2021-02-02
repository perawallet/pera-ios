//
//  MaximumBalanceWarningViewController.swift

import UIKit

class MaximumBalanceWarningViewController: BaseScrollViewController {

    override var shouldShowNavigationBar: Bool {
        return false
    }

    weak var delegate: MaximumBalanceWarningViewControllerDelegate?

    private lazy var maximumBalanceWarningView = MaximumBalanceWarningView()

    private let maximumBalanceWarningStorage = MaximumBalanceWarningStorage()

    private let account: Account

    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.backgroundColor = Colors.Background.secondary
        maximumBalanceWarningView.bind(MaximumBalanceWarningViewModel(account: account))
    }

    override func linkInteractors() {
        super.linkInteractors()
        maximumBalanceWarningView.delegate = self
    }

    override func prepareLayout() {
        super.prepareLayout()
        setupMaximumBalanceWarningViewLayout()
    }
}

extension MaximumBalanceWarningViewController {
    private func setupMaximumBalanceWarningViewLayout() {
        contentView.addSubview(maximumBalanceWarningView)

        maximumBalanceWarningView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension MaximumBalanceWarningViewController: MaximumBalanceWarningViewDelegate {
    func maximumBalanceWarningViewDidConfirmWarning(_ maximumBalanceWarningView: MaximumBalanceWarningView) {
        delegate?.maximumBalanceWarningViewControllerDidConfirmWarning(self)
    }

    func maximumBalanceWarningViewDidDisableShowing(_ maximumBalanceWarningView: MaximumBalanceWarningView) {
        maximumBalanceWarningStorage.setMaximumBalanceWarningDisabled(true)
        delegate?.maximumBalanceWarningViewControllerDidConfirmWarning(self)
    }

    func maximumBalanceWarningViewDidCancel(_ maximumBalanceWarningView: MaximumBalanceWarningView) {
        dismissScreen()
    }
}

protocol MaximumBalanceWarningViewControllerDelegate: class {
    func maximumBalanceWarningViewControllerDidConfirmWarning(_ maximumBalanceWarningViewController: MaximumBalanceWarningViewController)
}
