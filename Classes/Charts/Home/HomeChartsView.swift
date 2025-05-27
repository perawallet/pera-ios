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

//   HomeChartsView.swift

import MacaroonUIKit
import UIKit
import SwiftUI


final class HomeChartsView:
    UIView,
    ViewComposable,
    ListReusable {
    
    private var hostingController: UIHostingController<SUIChartView>?
    private var chartView: SUIChartView?

    func customize(_ theme: HomeChartsViewTheme) {
        addBackground(theme)
        addChartView(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ items: [CarouselBannerItemModel]) {
//        chartView?.chartValues = [0.0, 0.1, 0.2]
    }

    func prepareForReuse() {
    }
}

extension HomeChartsView {
    private func addBackground(_ theme: HomeChartsViewTheme) {
        customizeAppearance(theme.background)
    }
    
    private func addChartView(_ theme: HomeChartsViewTheme) {
        let suiChartView = SUIChartView()
        let controller = UIHostingController(rootView: suiChartView)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(controller.view)
        controller.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        hostingController = controller
        chartView = suiChartView
    }
}

