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
//   SendAssetAndOptInTransactionInfoScreenViewModel.swift

import MacaroonUIKit
import Foundation
import UIKit

struct SendAssetAndOptInTransactionInfoScreenViewModel: ViewModel {
    var headerViewImage: Image?
    var headerViewTitle: TextProvider?
    var headerViewText: TextProvider?
    
    var bodyViewTitle: TextProvider?
    var bodyViewText: [TextProvider]?
    
    init () {
        bindHeaderView()
        bindBodyView()
    }
}

extension SendAssetAndOptInTransactionInfoScreenViewModel {
    mutating func bindHeaderView() {
        headerViewImage = "img-transaction-info-express-send"
        headerViewTitle = String(localized: "express-send-title").bodyLargeMedium()
        
        let headerViewTextString = String(localized: "express-send-explanation")
        let headerViewTextAttributedString = NSMutableAttributedString(string: headerViewTextString)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 12
        paragraphStyle.lineSpacing = 9
        
        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[.paragraphStyle] = paragraphStyle
        attributes[.font] = Fonts.DMSans.regular.make(15).uiFont
        
        let range = NSMakeRange(0, headerViewTextString.count)
        headerViewTextAttributedString.addAttributes(
            attributes,
            range: range
        )
        
        headerViewText = headerViewTextAttributedString
    }
    
    mutating func bindBodyView() {
        bodyViewTitle = String(localized: "asset-transfer-title").bodyMedium()
        bodyViewText = [
            String(localized: "asset-transfer-explanation-part1").footnoteRegular(),
            String(localized: "asset-transfer-explanation-part2").footnoteRegular(),
            String(localized: "asset-transfer-explanation-part3").footnoteRegular()
        ]
    }

}
