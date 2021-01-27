//
//  AssetDisplayViewModel.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.01.2021.
//  Copyright © 2021 hippo. All rights reserved.
//

import UIKit

class AssetDisplayViewModel {
    private(set) var isVerified: Bool = false
    private(set) var name: String?
    private(set) var code: String?
    private(set) var codeColor: UIColor?
    private(set) var codeFont: UIFont?

    init(assetDetail: AssetDetail?) {
        if let assetDetail = assetDetail {
            setIsVerified(from: assetDetail)

            let displayNames = assetDetail.getDisplayNames()
            setName(from: displayNames)
            setCode(from: displayNames)
            setCodeFont(from: displayNames)
            setCodeColor(from: displayNames)
        }
    }

    private func setIsVerified(from assetDetail: AssetDetail) {
        isVerified = assetDetail.isVerified
    }

    private func setName(from displayNames: (String, String?)) {
        if !displayNames.0.isUnknown() {
            name = displayNames.0
        }
    }

    private func setCode(from displayNames: (String, String?)) {
        if displayNames.0.isUnknown() {
            code = displayNames.0
        } else {
            code = displayNames.1
        }
    }

    private func setCodeFont(from displayNames: (String, String?)) {
        if displayNames.0.isUnknown() {
            codeFont = UIFont.font(withWeight: .semiBoldItalic(size: 40.0))
        }
    }

    private func setCodeColor(from displayNames: (String, String?)) {
        if displayNames.0.isUnknown() {
            codeColor = Colors.General.unknown
        }
    }
}
