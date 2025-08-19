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

//   AlreadyImportedAddressCell.swift

import Foundation
import UIKit
import MacaroonUIKit

final class AlreadyImportedAddressCell:
    CollectionCell<AlreadyImportedAddressListItemView>,
    ViewModelBindable {

    override class var contextPaddings: LayoutPaddings {
        return theme.contextEdgeInsets
    }

    static let theme = AlreadyImportedAddressListItemTheme()

    private lazy var accessoryView = UIImageView()

    override func prepareLayout() {
        addContext()
        addSeparator()
        
        isUserInteractionEnabled = false
    }

    override func addContext() {
        let theme = Self.theme

        contextView.customize(theme)

        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == theme.contextEdgeInsets.top
            $0.leading == theme.contextEdgeInsets.leading
            $0.trailing == theme.contextEdgeInsets.trailing
            $0.bottom == theme.contextEdgeInsets.bottom
        }
    }
    
    private func addSeparator() {
        separatorStyle = .single(Self.theme.separator)
    }
}
