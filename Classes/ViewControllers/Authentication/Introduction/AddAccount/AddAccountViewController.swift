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
//  AddAccountViewController.swift

import UIKit

final class AddAccountViewController: BaseViewController {
    private lazy var addAccountView = AddAccountView()
    private lazy var theme = AddAccountViewTheme()
    
    private let flow: AccountSetupFlow
    
    init(flow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.flow = flow
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
    }
    
    override func configureAppearance() {
        setNavigationBarTertiaryBackgroundColor()
    }

    override func bindData() {
        addAccountView.bindCreateNewAccountView(AccountTypeViewModel(.add(type: .create)))
        addAccountView.bindWatchAccountView(AccountTypeViewModel(.add(type: .watch)))
        addAccountView.bindPairAccountView(AccountTypeViewModel(.add(type: .pair)))
    }
    
    override func linkInteractors() {
        addAccountView.delegate = self
    }

    override func setListeners() {
        addAccountView.setListeners()
    }
    
    override func prepareLayout() {
        addAccountView.customize(theme)
        prepareWholeScreenLayoutFor(addAccountView)
    }
}

extension AddAccountViewController {
    private func addBarButtons() {
        switch flow {
        case .addNewAccount:
            addCloseBarButtonItem()
        case .initializeAccount:
            addSkipBarButtonItem()
        case .none:
            break
        }
    }

    private func addCloseBarButtonItem() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            closeScreen(by: .dismiss, animated: true)
        }

        leftBarButtonItems = [closeBarButtonItem]
    }

    private func addSkipBarButtonItem() {
        let skipBarButtonItem = ALGBarButtonItem(kind: .skip) { [unowned self] in
            session?.createUser()

            DispatchQueue.main.async {
                self.dismiss(animated: false) {
                    UIApplication.shared.rootViewController()?.setupTabBarController()
                }
            }
        }

        rightBarButtonItems = [skipBarButtonItem]
    }
}

extension AddAccountViewController: AddAccountViewDelegate {
    func addAccountView(_ addAccountView: AddAccountView, didSelect type: AccountAdditionType) {
        switch type {
        case .create:
            open(.tutorial(flow: flow, tutorial: .backUp, isActionable: false), by: .push)
        case .watch:
            open(.tutorial(flow: flow, tutorial: .watchAccount, isActionable: false), by: .push)
        case .pair:
            open(.ledgerTutorial(flow: .addNewAccount(mode: .add(type: .pair))), by: .push)
        default:
            break
        }
    }
}
