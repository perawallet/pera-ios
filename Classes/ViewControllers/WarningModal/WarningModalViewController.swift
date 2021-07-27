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
//   WarningModalViewController.swift

import UIKit

class WarningModalViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    weak var delegate: WarningModalViewControllerDelegate?
    
    private lazy var warningModalView = WarningModalView()
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.secondary
    }
    
    override func setListeners() {
        warningModalView.delegate = self
    }
    
    override func prepareLayout() {
        prepareWholeScreenLayoutFor(warningModalView)
    }
}

extension WarningModalViewController: WarningModalViewDelegate {
    func warningModalViewDidTakeAction(_ warningModalView: WarningModalView) {
        delegate?.warningModalViewDidTakeAction(warningModalView)
    }
}

protocol WarningModalViewControllerDelegate: AnyObject {
    func warningModalViewDidTakeAction(_ warningModalView: WarningModalView)
}
