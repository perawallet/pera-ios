// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   DeveloperMenuViewController.swift

import SwiftUI

final class DeveloperMenuViewController: UIHostingController<DeveloperMenuListView> {
    
    // MARK: - Initialisers
    
    init(configuration: ViewControllerConfiguration) {
        let model = DeveloperMenuModel(featureFlagService: configuration.featureFlagService)
        super.init(rootView: DeveloperMenuListView(model: model))
        rootView.onBackPressed = { [weak self] in
            guard let self else { return }
            popScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: .empty, style: .plain, target: nil, action: nil)
    }
    
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
