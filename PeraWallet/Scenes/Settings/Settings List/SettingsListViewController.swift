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

//   SettingsListViewController.swift

import SwiftUI

final class SettingsListViewController: UIHostingController<SettingsListView> {
    
    // MARK: - Properties
    
    var onLegacyNavigationOptionSelected: ((SettingsListView.LegacyNavigationOption) -> Void)?
    var onClicksMissingToUnlock: ((Int) -> Void)?
    var onDevMenuUnlocked: (() -> Void)?
    var onLogoutButtonTap: (() -> Void)?
    
    // MARK: - Initialisers
    
    init(model: SettingsListModelable) {
        super.init(rootView: SettingsListView(model: model))
        rootView.onLegacyNavigationOptionSelected = { [weak self] in self?.onLegacyNavigationOptionSelected?($0) }
        rootView.onClicksMissingToUnlock = { [weak self] in self?.onClicksMissingToUnlock?($0) }
        rootView.onDevMenuUnlocked = { [weak self] in self?.onDevMenuUnlocked?() }
        rootView.onLogoutButtonTap = { [weak self] in self?.onLogoutButtonTap?() }
    }
    
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
