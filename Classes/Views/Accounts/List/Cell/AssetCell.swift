//
//  AssetCell.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class BaseAssetCell: BaseCollectionViewCell<AssetView> {
    weak var delegate: BaseAssetCellDelegate?
    
    override func setListeners() {
        contextView.delegate = self
    }

    func bind(_ viewModel: AssetViewModel) {
        contextView.bind(viewModel)
    }

    func bind(_ viewModel: AssetAdditionViewModel) {
        contextView.bind(viewModel)
    }

    func bind(_ viewModel: AssetRemovalViewModel) {
        contextView.bind(viewModel)
    }
}

extension BaseAssetCell: AssetViewDelegate {
    func assetViewDidTapActionButton(_ assetView: AssetView) {
        delegate?.assetCellDidTapActionButton(self)
    }
}

protocol BaseAssetCellDelegate: class {
    func assetCellDidTapActionButton(_ assetCell: BaseAssetCell)
}

extension BaseAssetCellDelegate {
    func assetCellDidTapActionButton(_ assetCell: BaseAssetCell) { }
}

class AssetCell: BaseAssetCell { }

class OnlyNameAssetCell: BaseAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.removeUnitName()
    }
}

class OnlyUnitNameAssetCell: BaseAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.removeName()
    }
}

class UnnamedAssetCell: BaseAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.setName("title-unknown".localized)
        contextView.assetNameView.nameLabel.textColor = Colors.General.unknown
        contextView.assetNameView.removeUnitName()
    }
}

class UnverifiedAssetCell: BaseAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.removeVerified()
    }
}

class UnverifiedOnlyNameAssetCell: BaseAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.removeUnitName()
        contextView.assetNameView.removeVerified()
    }
}

class UnverifiedOnlyUnitNameAssetCell: BaseAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.removeName()
        contextView.assetNameView.removeVerified()
    }
}

class UnverifiedUnnamedAssetCell: BaseAssetCell {
    override func configureAppearance() {
        super.configureAppearance()
        contextView.assetNameView.setName("title-unknown".localized)
        contextView.assetNameView.nameLabel.textColor = Colors.General.unknown
        contextView.assetNameView.removeUnitName()
        contextView.assetNameView.removeVerified()
    }
}
