//
//  LedgerAccountSelectionRekeyedInfoViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerAccountSelectionRekeyedInfoViewModel {
    
    private var addressInfoText: NSAttributedString?
    
    init(account: Account) {
        setAddressInfoText(from: account)
    }
    
    private func setAddressInfoText(from account: Account) {
        if let authAddress = account.authAddress?.shortAddressDisplay() {
            let fullString = "ledger-account-selection-ledger-rekeyed".localized(params: authAddress)
            let range = (fullString as NSString).range(of: authAddress)
            let attributedString = NSMutableAttributedString(
                attributedString: fullString.attributed([
                    .font(UIFont.font(withWeight: .regular(size: 14.0))),
                    .textColor(SharedColors.primaryText)
                ])
            )
            
            attributedString.addAttributes(
                [
                    .foregroundColor: SharedColors.primary,
                    .font: UIFont.font(withWeight: .medium(size: 14.0))
                ],
                range: range
            )
            addressInfoText = attributedString
        }
    }
}

extension LedgerAccountSelectionRekeyedInfoViewModel {
    func configure(_ view: LedgerAccountSelectionRekeyedInfoView) {
        view.setRekeyedAddress(addressInfoText)
    }
}
