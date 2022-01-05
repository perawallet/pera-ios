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
//   WCTransactionRequestView.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonBottomOverlay

final class WCTransactionRequestView: BaseView {
    private lazy var confirmButton = Button()
    private lazy var cancelButton = Button()

    private lazy var theme = WCTransactionRequestViewTheme()

    override func configureAppearance() {
        super.configureAppearance()

        confirmButton.customize(theme.confirmButton)
        confirmButton.setTitle("Confirm", for: .normal)
        cancelButton.customize(theme.cancelButton)
        cancelButton.setTitle("Cancel", for: .normal)
    }

    override func prepareLayout() {
        super.prepareLayout()

        addButtons()
    }
}

extension WCTransactionRequestView {
    private func addButtons() {

    }
}
