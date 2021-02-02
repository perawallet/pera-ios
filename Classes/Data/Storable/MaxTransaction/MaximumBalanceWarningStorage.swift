//
//  MaximumBalanceWarningStorage.swift

import Foundation

struct MaximumBalanceWarningStorage: Storable {
    typealias Object = Any

    private let maximumBalanceWarningKey = "com.algorand.algorand.transaction.max.balance.warning"

    func setMaximumBalanceWarningDisabled(_ isDisabled: Bool) {
        save(isDisabled, for: maximumBalanceWarningKey, to: .defaults)
    }

    func isMaximumBalanceWarningDisabled() -> Bool {
        return bool(with: maximumBalanceWarningKey, to: .defaults)
    }
}
