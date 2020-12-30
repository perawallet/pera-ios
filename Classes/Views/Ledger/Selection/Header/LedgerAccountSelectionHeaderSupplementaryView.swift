//
//  LedgerAccountSelectionHeaderSupplementaryView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 10.08.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerAccountSelectionHeaderSupplementaryView: BaseSupplementaryView<LedgerAccountSelectionHeaderView> {
    static func calculatePreferredSize() -> CGSize {
        return LedgerAccountSelectionHeaderView.calculatePreferredSize(with: Layout<LedgerAccountSelectionHeaderView.LayoutConstants>())
    }
    
    func bind(_ viewModel: LedgerAccountSelectionHeaderSupplementaryViewModel) {
        contextView.bind(viewModel)
    }
}
