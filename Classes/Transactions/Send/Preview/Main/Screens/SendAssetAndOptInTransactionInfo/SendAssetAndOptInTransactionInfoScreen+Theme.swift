// Copyright 2024 Pera Wallet, LDA

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
//   SendAssetAndOptInTransactionInfoScreen+Theme.swift

import Foundation
import MacaroonUIKit
import UIKit

extension SendAssetAndOptInTransactionInfoScreen {
    struct Theme: LayoutSheet, StyleSheet {
        let background: Color
        
        let headerViewBackground: Color
        let headerViewHeight: CGFloat
        let headerViewImageTopConstraint: CGFloat
        let headerViewLabelConstraint: CGFloat
        let headerViewContentEdgeInsets: NSDirectionalEdgeInsets
        
        let bodyViewTitleHeight: CGFloat
        let bodyViewTitleContentEdgeInsets: NSDirectionalEdgeInsets
        let bodyViewBulletNumberTextWidth: CGFloat
        let bodyViewBulletTextLineSpacing: CGFloat
        let bodyViewBulletTextSpacing: CGFloat
        let bodyViewBulletStackViewSpacing: CGFloat
        let bodyViewTextContentEdgeInsets: NSDirectionalEdgeInsets
        
        let continueButtonStyle: ButtonPrimaryTheme
        let dontShowAgainButtonStyle: ButtonSecondaryTheme
        let stackViewContentEdgeInsets: NSDirectionalEdgeInsets
        let stackViewSpacing: CGFloat
        
        init(_ family: LayoutFamily) {
            self.background = Colors.Defaults.background
            
            // Header view
            self.headerViewBackground = Colors.Other.Global.gray98
            self.headerViewHeight = 340
            self.headerViewImageTopConstraint = 64
            self.headerViewLabelConstraint = 24
            self.headerViewContentEdgeInsets = .zero
            
            // Body view
            self.bodyViewTitleHeight = 24
            self.bodyViewTitleContentEdgeInsets = .init(top: 32, leading: 24, bottom: 0, trailing: 24)
            self.bodyViewBulletNumberTextWidth = 22
            self.bodyViewBulletTextLineSpacing = 6
            self.bodyViewBulletTextSpacing = 16
            self.bodyViewBulletStackViewSpacing = 20
            self.bodyViewTextContentEdgeInsets = .init(top: 24, leading: 24, bottom: 24, trailing: 40)
            
            // Footer view with buttons
            self.continueButtonStyle = ButtonPrimaryTheme(family)
            self.dontShowAgainButtonStyle = ButtonSecondaryTheme(family)
            self.stackViewContentEdgeInsets = .init(top: 8, leading: 24, bottom: 46, trailing: 24)
            self.stackViewSpacing = 16
        }
    }
}
