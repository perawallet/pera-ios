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
//  EditAccountViewController.swift

import UIKit

// <todo>: Handle keyboard 
final class EditAccountViewController: BaseViewController {
    private lazy var theme = Theme()
    private lazy var editAccountView = EditAccountView()

    private let account: Account

    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        title = "options-edit-account-name".localized
    }
    
    override func setListeners() {
        editAccountView.delegate = self
    }
    
    override func prepareLayout() {
        editAccountView.customize(theme.editAccountViewTheme)
        view.addSubview(editAccountView)
        editAccountView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func bindData() {
        editAccountView.bindData(account.name)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        editAccountView.beginEditing()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        editAccountView.endEditing()
    }
}

extension EditAccountViewController {
    private func didTapDoneButton() {
        guard let name = editAccountView.accountNameInputView.text else {
            displaySimpleAlertWith(
                title: "title-error".localized,
                message: "account-name-setup-empty-error-message".localized
            )
            return
        }

        account.name = name
        session?.updateName(name, for: account.address)
        dismissScreen()
    }
}

extension EditAccountViewController: EditAccountViewDelegate {
    func editAccountViewDidTapDoneButton(_ editAccountView: EditAccountView) {
        didTapDoneButton()
    }
}
