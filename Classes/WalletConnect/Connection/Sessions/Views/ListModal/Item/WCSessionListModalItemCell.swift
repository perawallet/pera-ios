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
//   WCSessionListModalItemCell.swift

import UIKit

final class WCSessionListModalItemCell: BaseCollectionViewCell<WCSessionListModalItemView> {
    weak var delegate: WCSessionListModalItemCellDelegate?

    override func prepareLayout() {
        super.prepareLayout()
        contextView.customize(WCSessionsListModalItemViewTheme())
    }

    override func linkInteractors() {
        super.linkInteractors()
        contextView.setListeners()
        contextView.delegate = self
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contextView.prepareForReuse()
    }
}

extension WCSessionListModalItemCell {
    func bindData(_ viewModel: WCSessionsListModalItemViewModel) {
        contextView.bindData(viewModel)
    }
}

extension WCSessionListModalItemCell: WCSessionListModalItemViewDelegate {
    func wcSessionListModalItemViewDidOpenDisconnectionMenu(_ wcSessionListModalView: WCSessionListModalItemView) {
        delegate?.wcSessionListModalItemCellDidOpenDisconnectionMenu(self)
    }
}

protocol WCSessionListModalItemCellDelegate: AnyObject {
    func wcSessionListModalItemCellDidOpenDisconnectionMenu(_ wcSessionItemCell: WCSessionListModalItemCell)
}
