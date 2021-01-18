//
//  PendingAssetCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 10.12.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class BasePendingAssetCell: BaseCollectionViewCell<PendingAssetView> {

    func bind(_ viewModel: PendingAssetViewModel) {
        contextView.bind(viewModel)
    }
}

class PendingAssetCell: BasePendingAssetCell { }

class PendingOnlyNameAssetCell: BasePendingAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.removeVerified()
    }
}

class PendingOnlyUnitNameAssetCell: BasePendingAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.removeVerified()
    }
}

class PendingUnnamedAssetCell: BasePendingAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.setName("title-unknown".localized)
        contextView.assetNameView.nameLabel.textColor = Colors.General.unknown
        contextView.assetNameView.removeUnitName()
        contextView.assetNameView.removeVerified()
    }
}

class PendingUnverifiedAssetCell: BasePendingAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.removeVerified()
    }
}

class PendingUnverifiedOnlyNameAssetCell: BasePendingAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.removeVerified()
    }
}

class PendingUnverifiedOnlyUnitNameAssetCell: BasePendingAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.removeVerified()
    }
}

class PendingUnverifiedUnnamedAssetCell: BasePendingAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.setName("title-unknown".localized)
        contextView.assetNameView.nameLabel.textColor = Colors.General.unknown
        contextView.assetNameView.removeUnitName()
        contextView.assetNameView.removeVerified()
    }
}
