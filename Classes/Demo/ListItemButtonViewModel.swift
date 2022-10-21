// Copyright 2022 Pera Wallet, LDA

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
//   ListItemButtonViewModel.swift

import Foundation
import MacaroonUIKit

protocol ListItemButtonViewModel: ViewModel {
    var icon: Image? { get }
    var isBadgeVisible: Bool { get }
    var title: EditText? { get }
    var subtitle: EditText? { get }
    var accessory: Image? { get }
}

extension ListItemButtonViewModel {
    var isBadgeVisible: Bool {
        return false
    }
    
    var accessory: Image? {
        return nil
    }
}

extension ListItemButtonViewModel {
    static func getTitle(
        _ aTitle: String?,
        _ aTitleColor: Color? = nil
    ) -> EditText? {
        guard let aTitle = aTitle else {
            return nil
        }

        var attributes = Typography.bodyMediumAttributes()

        if let textColor = aTitleColor {
            attributes.insert(.textColor(textColor))
        }

        return .attributedString(
            aTitle.attributed(
                attributes
            )
        )
    }
    
    static func getSubtitle(
        _ aSubtitle: String?
    ) -> EditText? {
        guard let aSubtitle = aSubtitle else {
            return nil
        }
        
        return .attributedString(
            aSubtitle.captionMonoRegular(
                lineBreakMode: .byTruncatingMiddle
            )
        )
    }
}
