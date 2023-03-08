// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ManageAssetsListItemLoadingCell.swift

import Foundation
import MacaroonUIKit

final class ManageAssetsListItemLoadingCell: CollectionCell<ManageAssetsListItemLoadingView> {
    override class var contextPaddings: LayoutPaddings {
        return (8, 24, 8, 24)
    }
    
    static let theme = ManageAssetsListItemLoadingViewTheme()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contextView.customize(Self.theme)
    }
}

extension ManageAssetsListItemLoadingCell {
    static func calculatePreferredSize(
        for theme: ManageAssetsListItemLoadingViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let contextHorizontalPaddings = contextPaddings.leading + contextPaddings.trailing
        let maxWidth = size.width - contextHorizontalPaddings
        let preferredSize = ContextView.calculatePreferredSize(
            for: theme,
            fittingIn: CGSize(width: maxWidth, height: size.height)
        )
        let width = (preferredSize.width + contextHorizontalPaddings).ceil()
        let height = (preferredSize.height + contextPaddings.top + contextPaddings.bottom).ceil()
        return CGSize(width: width, height: height)
    }
}

extension ManageAssetsListItemLoadingCell {
    func startAnimating() {
        contextView.startAnimating()
    }
    
    func stopAnimating() {
        contextView.stopAnimating()
    }
}
