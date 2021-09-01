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

class AddAccountViewController: BaseViewController {
    
    private lazy var addAccountView = AddAccountView()
    private lazy var theme = Theme()
    
    private let flow: AccountSetupFlow
    
    init(flow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.flow = flow
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        setNavigationBarTertiaryBackgroundColor()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func bindData() {
        addAccountView.bindCreateNewAccountView(AccountTypeViewModel(.add(type: .create)))
        addAccountView.bindWatchAccountView(AccountTypeViewModel(.add(type: .watch)))
        addAccountView.bindPairAccountView(AccountTypeViewModel(.add(type: .pair)))
    }
    
    override func linkInteractors() {
        addAccountView.delegate = self
    }
    
    override func prepareLayout() {
        addAccountView.customize(theme.addAccountViewTheme)
        
        prepareWholeScreenLayoutFor(addAccountView)
    }
}

extension AddAccountViewController: AddAccountViewDelegate {
    func addAccountView(_ addAccountView: AddAccountView, didSelect type: AccountAdditionType) {
        switch type {
        case .create:
            open(.tutorial(flow: flow, tutorial: .backUp), by: .push)
        case .watch:
            open(.tutorial(flow: flow, tutorial: .watchAccount), by: .push)
        case .pair:
            open(.tutorial(flow: flow, tutorial: .ledger), by: .push)
        default:
            break
        }
    }
}
