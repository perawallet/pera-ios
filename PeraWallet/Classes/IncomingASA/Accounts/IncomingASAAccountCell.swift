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

//   IncomingASAAccountCell.swift

import MacaroonUIKit
import UIKit

final class IncomingASAAccountCell: CollectionCell<IncomingASAAccountView>, InboxRowIdentifiable {
        
    // MARK: - Properties - IndexRowIdentifiable
        
    var identifier: InboxRowIdentifier?
    
    // MARK: - Properties
    
    override static var contextPaddings: LayoutPaddings { (16.0, 24.0, 16.0, 24.0) }
    static let theme = IncomingASAAccountViewTheme()

    // MARK: - Initialisers
    
    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        contextView.customize(Self.theme)
        
        let separator = Separator(
            color: Colors.Layer.grayLighter,
            size: 1,
            position: .bottom((80, 24))
        )
        separatorStyle = .single(separator)
    }
    
    // MARK: - Update
    
    func update(icon: ImageType, title: String, primaryAccessory: String) {
        contextView.update(icon: icon, title: title, primaryAccessory: primaryAccessory)
    }
}
