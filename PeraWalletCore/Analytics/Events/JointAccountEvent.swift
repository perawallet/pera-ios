// Copyright 2022-2026 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   JointAccountEvent.swift

import Foundation
import MacaroonVendors

public struct JointAccountEvent: ALGAnalyticsEvent {
    public let name: ALGAnalyticsEventName
    public let metadata: ALGAnalyticsMetadata

    fileprivate init(
        type: Type
    ) {
        self.name = type.rawValue
        self.metadata = [:]
    }
}

extension JointAccountEvent {
    public enum `Type` {
        case welcomePressed
        case addAccount
        case editAccount
        case removeAddress
        case addAccountContinue
        case addAccountContinueFromInbox
        case thresholdContinue
        case nameAccount
        case infoScreenProceed
        case infoScreenGoBack
        case cancelTransaction
        case confirmTransaction
        case declinePendingTransaction
        case closeForNow
        case invitePressed
        case inviteIgnorePressed
        case inviteAddPressed
        case copyUrl
        case shareUrl
        case showPendingTransaction
        case closePendingTransaction

        public var rawValue: ALGAnalyticsEventName {
            switch self {
            case .welcomePressed:
                return .jointAccountWelcomePressed
            case .addAccount:
                return .jointAccountAddAccount
            case .editAccount:
                return .jointAccountEditAccount
            case .removeAddress:
                return .jointAccountRemoveAddress
            case .addAccountContinue:
                return .jointAccountAddAccountContinue
            case .addAccountContinueFromInbox:
                return .jointAccountAddAccountContinueFromInbox
            case .thresholdContinue:
                return .jointAccountThresholdContinue
            case .nameAccount:
                return .jointAccountNameAccount
            case .infoScreenProceed:
                return .jointAccountInfoScreenProceed
            case .infoScreenGoBack:
                return .jointAccountInfoScreenGoBack
            case .cancelTransaction:
                return .jointAccountCancelTransaction
            case .confirmTransaction:
                return .jointAccountConfirmTransaction
            case .declinePendingTransaction:
                return .jointAccountDeclinePendingTransaction
            case .closeForNow:
                return .jointAccountCloseForNow
            case .invitePressed:
                return .jointAccountInvitePressed
            case .inviteIgnorePressed:
                return .jointAccountInviteIgnorePressed
            case .inviteAddPressed:
                return .jointAccountInviteAddPressed
            case .copyUrl:
                return .jointAccountCopyUrl
            case .shareUrl:
                return .jointAccountShareUrl
            case .showPendingTransaction:
                return .jointAccountShowPendingTransaction
            case .closePendingTransaction:
                return .jointAccountClosePendingTransaction
            }
        }
    }
}

extension AnalyticsEvent where Self == JointAccountEvent {
    public static func jointAccount(
        type: JointAccountEvent.`Type`
    ) -> Self {
        return JointAccountEvent(type: type)
    }
}
