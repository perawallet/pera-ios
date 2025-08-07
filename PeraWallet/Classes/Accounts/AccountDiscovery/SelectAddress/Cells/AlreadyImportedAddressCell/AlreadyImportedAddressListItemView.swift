// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AlreadyImportedAddressListItemView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AlreadyImportedAddressListItemView:
    View,
    ViewModelBindable,
    ListReusable {
    private lazy var titleView = UILabel()
    private lazy var alreadyImportedView = UILabel()

    func customize(
        _ theme: AlreadyImportedAddressListItemTheme
    ) {
        addTitle(theme)
        addAlreadyImportedView(theme)
    }

    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}

    func bindData(
        _ viewModel: AlreadyImportedAddressListItemViewModel?
    ) {
        titleView.text = viewModel?.title?.string
    }
}

extension AlreadyImportedAddressListItemView {

    private func addTitle(
        _ theme: AlreadyImportedAddressListItemTheme
    ) {
        titleView.customizeAppearance(theme.titleTheme.title)

        addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing <= 0
        }
    }
    
    private func addAlreadyImportedView(
        _ theme: AlreadyImportedAddressListItemTheme
    ) {
        alreadyImportedView.customizeAppearance(theme.textTheme.text)
        alreadyImportedView.roundTheCorners(.allCorners, radius: 8)
        
        addSubview(alreadyImportedView)
        alreadyImportedView.snp.makeConstraints {
            $0.centerY == titleView.snp.centerY
            $0.trailing == 0
            $0.width.equalTo(121)
            $0.height.equalTo(24)
        }
    }

}
