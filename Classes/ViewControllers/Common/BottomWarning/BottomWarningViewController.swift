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
//  BottomWarningViewController.swift

import UIKit

final class BottomWarningViewController: BaseViewController {
    override var shouldShowNavigationBar: Bool {
        return false
    }

    private let viewConfigurator: BottomWarningViewConfigurator

    init(_ viewModel: BottomWarningViewConfigurator, configuration: ViewControllerConfiguration) {
        self.viewConfigurator = viewModel
        super.init(configuration: configuration)
    }

    private lazy var theme = Theme()
    private lazy var bottomWarningView = BottomWarningView()

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }

    override func setListeners() {
        bottomWarningView.delegate = self
    }

    override func prepareLayout() {
        bottomWarningView.customize(theme.bottomWarningViewTheme)
        prepareWholeScreenLayoutFor(bottomWarningView)
    }

    override func bindData() {
        bottomWarningView.bindData(viewConfigurator)
    }
}

extension BottomWarningViewController: BottomWarningViewDelegate {
    func bottomWarningViewDidTapPrimaryActionButton(_ bottomWarningView: BottomWarningView) {
        viewConfigurator.primaryAction?()
        dismissScreen()
    }

    func bottomWarningViewDidTapSecondaryActionButton(_ bottomWarningView: BottomWarningView) {
        dismissScreen()
    }
}
