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

//   NFTsUIActionsView.swift

import UIKit
import MacaroonUIKit

final class NFTsUIActionsView:
    View,
    ListReusable,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .performLayoutPreferenceChange: TargetActionInteraction()
    ]
    
    weak var searchInputDelegate: SearchInputViewDelegate? {
        didSet {
            searchInputView.delegate = searchInputDelegate
        }
    }

    private lazy var searchInputView = SearchInputView()
    private lazy var layoutPreferenceSelectionView = SegmentedControl(theme.layoutPreferenceSegmentedControl)

    private(set) var layoutPreference: NFTsScreenLayoutPreference = .grid

    private var theme: NFTsUIActionsViewTheme!

    func customize(_ theme: NFTsUIActionsViewTheme) {
        self.theme = theme

        addBackground(theme)
        addSearchInput(theme)
        addAction(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    static func calculatePreferredSize(
        for theme: NFTsUIActionsViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        return CGSize((size.width, theme.searchInput.intrinsicHeight))
    }
}

extension NFTsUIActionsView {
    private func addBackground(_ theme: NFTsUIActionsViewTheme) {
        customizeAppearance(theme.background)
    }

    private func addSearchInput(_ theme: NFTsUIActionsViewTheme) {
        searchInputView.customize(theme.searchInput)

        addSubview(searchInputView)
        searchInputView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
        }
    }

    private func addAction(_ theme: NFTsUIActionsViewTheme) {
        addSubview(layoutPreferenceSelectionView)
        layoutPreferenceSelectionView.fitToIntrinsicSize()
        layoutPreferenceSelectionView.snp.makeConstraints {
            $0.top == 0
            $0.leading == searchInputView.snp.trailing + theme.spacingBetweenSearchInputAndLayoutPreferenceSegmentedControl
            $0.trailing == 0
            $0.bottom == 0
        }

        layoutPreferenceSelectionView.add(segments: theme.segments)
        
        layoutPreferenceSelectionView.addTarget(
            self,
            action: #selector(performLayoutPreferenceChangeIfNeeded),
            for: .valueChanged
        )

        updateLayoutPreferenceIfNeeded(
            new: .grid,
            force: true
        )
    }
}

extension NFTsUIActionsView {
    func beginEditing() {
        searchInputView.beginEditing()
    }
}

extension NFTsUIActionsView {
    func updateLayoutPreferenceIfNeeded(
        new: NFTsScreenLayoutPreference,
        force: Bool = false
    ) {
        if !shouldUpdateLayoutPreference(
            new: new,
            force: force
        ) {
            return
        }

        layoutPreferenceSelectionView.selectedSegmentIndex = new.rawValue

        layoutPreference = new
    }

    @objc
    private func performLayoutPreferenceChangeIfNeeded() {
        let preference = NFTsScreenLayoutPreference(rawValue: layoutPreferenceSelectionView.selectedSegmentIndex)

        guard let preference = preference else {
            assertionFailure("layoutPreferenceSelectionView.selectedSegmentIndex should match with some rawValue of NFTsScreenLayoutPreference")
            return
        }

        if !shouldUpdateLayoutPreference(new: preference) {
            return
        }

        layoutPreference = preference

        publishLayoutPreferenceChange()
    }

    private func shouldUpdateLayoutPreference(
        new: NFTsScreenLayoutPreference,
        force: Bool = false
    ) -> Bool {
        let old = layoutPreference
        let shouldUpdate = force || old != new
        return shouldUpdate
    }

    private func publishLayoutPreferenceChange() {
        let uiInteraction = uiInteractions[.performLayoutPreferenceChange]
        uiInteraction?.publish()
    }
}

extension NFTsUIActionsView {
    enum Event {
        case performLayoutPreferenceChange
    }
}
