// Copyright 2019 Algorand, Inc.

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
//  AssetPreviewSendCell.swift

import UIKit

final class AssetPreviewSendCell: BaseCollectionViewCell<AssetPreviewSendView> {
    weak var delegate: AssetPreviewSendCellDelegate?
    
    override func setListeners() {
        super.setListeners()
        contextView.delegate = self
    }

    func customize(_ theme: AssetPreviewSendViewTheme) {
        contextView.customize(theme)
    }

    func bindData(_ viewModel: AssetPreviewViewModel) {
        contextView.bindData(viewModel)
    }
}

extension AssetPreviewSendCell: AssetPreviewSendViewDelegate {
    func assetPreviewSendViewDidTapSendButton(_ assetPreviewSendView: AssetPreviewSendView) {
        delegate?.assetPreviewSendCellDidTapSendButton(self)
    }
}

protocol AssetPreviewSendCellDelegate: AnyObject {
    func assetPreviewSendCellDidTapSendButton(_ assetPreviewSendCell: AssetPreviewSendCell)
}
