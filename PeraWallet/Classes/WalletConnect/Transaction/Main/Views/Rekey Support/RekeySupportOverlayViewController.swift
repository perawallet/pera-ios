// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   RekeySupportOverlayViewController.swift

import UIKit
import MacaroonBottomSheet

final class RekeySupportOverlayViewController: BaseScrollViewController, BottomSheetScrollPresentable {
    
    // MARK: - Properties
    
    var onPrimaryButtonTap: (() -> Void)?
    private let mainView: RekeySupportOverlayView
    
    // MARK: - Initialisers
    
    init(configuration: ViewControllerConfiguration, variant: RekeySupportOverlayView.Variant) {
        mainView = RekeySupportOverlayView(variant: variant)
        super.init(configuration: configuration)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainView()
        setupCallbacks()
    }
    
    // MARK: - Setups
    
    private func setupMainView() {
        mainView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainView)
        
        let constraints = [
            mainView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupCallbacks() {
        
        mainView.onPrimaryButtonTap = { [weak self] in
            self?.dismiss(animated: true) {
                self?.onPrimaryButtonTap?()
            }
        }
        
        mainView.onSecondaryButtonTap = { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}
