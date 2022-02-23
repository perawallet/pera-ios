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

//   MoonpayTransactionViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct MoonpayTransactionViewModel: ViewModel {
    private(set) var image: Image?
    private(set) var title: EditText?
    private(set) var description: EditText?
    private(set) var accountName: EditText?
    private(set) var accountIcon: Image?
    
    init(
        status: MoonpayParams.TransactionStatus,
        name: String,
        type: AccountType
    ) {
        bindImage(status)
        bindTitle(status)
        bindDescription(status)
        bindAccountName(name)
        bindAccountIcon(type)
    }
}

/// <todo>
/// Refactor image, title and description when the design gets an update.
extension MoonpayTransactionViewModel {
    private mutating func bindImage(_ type: MoonpayParams.TransactionStatus) {
        switch type {
        case .completed:
            image = "icon-moonpay-transaction-completed"
        case .pending:
            image = "icon-moonpay-transaction-pending"
        case .rejected:
            image = "icon-moonpay-transaction-pending"
        }
    }
    
    private mutating func bindTitle(_ type: MoonpayParams.TransactionStatus) {
        let font = Fonts.DMSans.medium.make(32).uiFont
        let lineHeightMultiplier = 0.96
        let titleString: String
        
        switch type {
        case .completed:
            titleString = "moonpay-transaction-title-completed"
        case .pending:
            titleString = "moonpay-transaction-title-pending"
        case .rejected:
            titleString = "moonpay-transaction-title-pending"
        }
        
        title = .attributedString(
            titleString
                .localized
                .attributed(
                    [
                        .font(font),
                        .lineHeightMultiplier(lineHeightMultiplier, font),
                        .paragraph([
                            .textAlignment(.left),
                            .lineHeightMultiple(lineHeightMultiplier)
                        ]),
                    ]
                )
        )
    }
    
    private mutating func bindDescription(_ type: MoonpayParams.TransactionStatus) {
        let font = Fonts.DMSans.regular.make(15).uiFont
        let lineHeightMultiplier = 1.23
        let descriptionString: String
        
        switch type {
        case .completed:
            descriptionString = "moonpay-transaction-description-pending"
        case .pending:
            descriptionString = "moonpay-transaction-description-pending"
        case .rejected:
            descriptionString = "moonpay-transaction-description-pending"
        }

        description = .attributedString(
            descriptionString
                .localized
                .attributed(
                    [
                        .font(font),
                        .lineHeightMultiplier(lineHeightMultiplier, font),
                        .paragraph([
                            .textAlignment(.left),
                            .lineBreakMode(.byWordWrapping),
                            .lineHeightMultiple(lineHeightMultiplier)
                        ]),
                    ]
                )
        )
    }
    
    private mutating func bindAccountName(_ name: String) {
        let font = Fonts.DMSans.regular.make(15).uiFont
        let lineHeightMultiplier = 1.23
        
        accountName = .attributedString(name
            .attributed(
                [
                    .font(font),
                    .lineHeightMultiplier(lineHeightMultiplier, font),
                    .paragraph([
                        .textAlignment(.left),
                        .lineBreakMode(.byWordWrapping),
                        .lineHeightMultiple(lineHeightMultiplier)
                    ]),
                ]
            )
        )
    }
    
    private mutating func bindAccountIcon(_ type: AccountType) {
        accountIcon = type.image(for: AccountImageType.getRandomImage(for: type))
    }
}
