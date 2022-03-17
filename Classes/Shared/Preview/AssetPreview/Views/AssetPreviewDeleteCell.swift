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

//   AssetPreviewDeleteCell.swift

import UIKit

final class AssetPreviewDeleteCell: BaseCollectionViewCell<AssetPreviewDeleteView> {
    weak var delegate: AssetPreviewDeleteCellDelegate?
    
    override func setListeners() {
        super.setListeners()
        contextView.delegate = self
    }
    func customize(_ theme: AssetPreviewDeleteViewTheme) {
        contextView.customize(theme)
    }
    
    func bindData(_ viewModel: AssetPreviewViewModel) {
        contextView.bindData(viewModel)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.prepareForReuse()
    }
}

extension AssetPreviewDeleteCell: AssetPreviewDeleteViewDelegate {
    func assetPreviewDeleteViewDidDelete(_ assetPreviewDeleteView: AssetPreviewDeleteView) {
        delegate?.assetPreviewDeleteCellDidDelete(self)
    }
}

protocol AssetPreviewDeleteCellDelegate: AnyObject {
    func assetPreviewDeleteCellDidDelete(_ assetPreviewDeleteCell: AssetPreviewDeleteCell)
}
