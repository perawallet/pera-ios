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
//   PortfolioCalculationInfoViewController.swift

import Foundation
import MacaroonUIKit
import UIKit

final class PortfolioCalculationInfoViewController: BaseScrollViewController {
    private let theme: PortfolioCalculationInfoViewControllerTheme
    
    init(
        configuration: ViewControllerConfiguration,
        theme: PortfolioCalculationInfoViewControllerTheme = .init()
    ) {
        self.theme = theme
        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }
    
    private func build() {
        addBackground()
    }
}

extension PortfolioCalculationInfoViewController {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }
    
    private func addError() {
        let errorView = ErrorView()
        
        errorView.customize(theme.error)
        
        contentView.addSubview(errorView)
        errorView.snp.makeConstraints {
            $0.top == theme.contentPaddings.top
            $0.leading == theme.contentPaddings.leading
        }
    }
}
