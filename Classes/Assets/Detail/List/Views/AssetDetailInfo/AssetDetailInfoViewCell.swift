// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   AssetDetailInfoViewCell.swift

import UIKit

final class AssetDetailInfoViewCell: BaseCollectionViewCell<AssetDetailInfoView> {
    weak var delegate: AssetDetailInfoViewCellDelegate?

    override func prepareLayout() {
        super.prepareLayout()
        contextView.customize(AssetDetailInfoViewTheme())
    }

    override func setListeners() {
        contextView.setListeners()
        contextView.delegate = self
    }

    func bindData(_ viewModel: AssetDetailInfoViewModel?) {
        contextView.bindData(viewModel)
    }
}

extension AssetDetailInfoViewCell: AssetDetailInfoViewDelegate {
    func assetDetailInfoViewDidTapAssetID(_ assetDetailInfoView: AssetDetailInfoView, assetID: String?) {
        delegate?.assetDetailInfoViewCellDidTapAssetID(self, assetID: assetID)
    }
}

protocol AssetDetailInfoViewCellDelegate: AnyObject {
    func assetDetailInfoViewCellDidTapAssetID(_ assetDetailInfoViewCell: AssetDetailInfoViewCell, assetID: String?)
}
