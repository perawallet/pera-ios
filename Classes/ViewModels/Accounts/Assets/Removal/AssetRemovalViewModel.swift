//
//  AssetRemovalViewModel.swift

import UIKit

class AssetRemovalViewModel {
    private(set) var assetDetail: AssetDetail?
    private(set) var actionFont: UIFont?
    private(set) var actionColor: UIColor?
    private(set) var actionText: String?

    init(assetDetail: AssetDetail) {
        setAssetDetail(from: assetDetail)
        setActionFont()
        setActionColor()
        setActionText()
    }

    private func setAssetDetail(from assetDetail: AssetDetail) {
        self.assetDetail = assetDetail
    }

    private func setActionFont() {
        actionFont = UIFont.font(withWeight: .semiBold(size: 14.0))
    }

    private func setActionColor() {
        actionColor = Colors.General.error
    }

    private func setActionText() {
        actionText = "title-remove".localized
    }
}
