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
//  AccountNameSwitchCell.swift

import UIKit

class AccountNameSwitchCell: BaseCollectionViewCell<AccountNameSwitchView> {

    weak var delegate: AccountNameSwitchCellDelegate?

    override func linkInteractors() {
        super.linkInteractors()
        contextView.delegate = self
    }
}

extension AccountNameSwitchCell {
    func bind(_ viewModel: AccountNameSwitchViewModel) {
        contextView.bind(viewModel)
    }
}

extension AccountNameSwitchCell: AccountNameSwitchViewDelegate {
    func accountNameSwitchView(_ accountNameSwitchView: AccountNameSwitchView, didChangeToggleValue value: Bool) {
        delegate?.accountNameSwitchCell(self, didChangeToggleValue: value)
    }
}

protocol AccountNameSwitchCellDelegate: AnyObject {
    func accountNameSwitchCell(_ accountNameSwitchCell: AccountNameSwitchCell, didChangeToggleValue value: Bool)
}
