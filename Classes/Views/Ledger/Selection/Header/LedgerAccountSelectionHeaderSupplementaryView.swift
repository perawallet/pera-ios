//
//  LedgerAccountSelectionHeaderSupplementaryView.swift

import UIKit

class LedgerAccountSelectionHeaderSupplementaryView: BaseSupplementaryView<LedgerAccountSelectionHeaderView> {
    static func calculatePreferredSize() -> CGSize {
        return LedgerAccountSelectionHeaderView.calculatePreferredSize(with: Layout<LedgerAccountSelectionHeaderView.LayoutConstants>())
    }
    
    func bind(_ viewModel: LedgerAccountSelectionHeaderSupplementaryViewModel) {
        contextView.bind(viewModel)
    }
}
