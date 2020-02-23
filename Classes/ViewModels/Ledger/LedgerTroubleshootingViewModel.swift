//
//  LedgerTroubleshootingViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 23.02.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerTroubleshootingViewModel {
    func configure(_ cell: LedgerTroubleshootingOptionCell, with troubleshootOption: LedgerTroubleshootOption) {
        cell.contextView.setNumber("\(troubleshootOption.number.rawValue)")
        
        if troubleshootOption.number == .ledgerSupport {
            let initialString = troubleshootOption.option.attributed()
            let ledgerString = "ledger-troubleshooting-ledger-support-title".localized.attributed([.textColor(SharedColors.purple)])
            let totalString = initialString + ledgerString
            cell.contextView.setAttributedTitle(totalString)
        } else {
            cell.contextView.setTitle(troubleshootOption.option)
        }
    }
    
    func sizeFor(_ troubleshootOption: LedgerTroubleshootOption) -> CGSize {
        let titleLabelHorizontalInsetsTotal: CGFloat = 75.0
        let titleLabelVerticalInsetsTotal: CGFloat = 28.0
        let textHeight = troubleshootOption.option.height(
            withConstrained: UIScreen.main.bounds.width - titleLabelHorizontalInsetsTotal,
            font: UIFont.font(.avenir, withWeight: .medium(size: 14.0))
        )
        return CGSize(width: UIScreen.main.bounds.width, height: textHeight + titleLabelVerticalInsetsTotal)
    }
}
