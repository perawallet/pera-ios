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

//   ASAHoldingsFragmentHeaderView.swift

import UIKit

final class ASAHoldingsFragmentHeaderView: UICollectionReusableView {
    private lazy var contentViewContainer = ASAHoldingsHeaderContentView()
    private var lastBoundChartData: ChartViewData?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentViewContainer)
        contentViewContainer.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(context: ASAHoldingsHeaderContext) {
        contentViewContainer.bind(context: context)
        if let data = lastBoundChartData {
            contentViewContainer.updateChart(with: data)
        }
    }
    
    func bindFavoriteAndNotificationButtons(isAssetPriceAlertEnabled: Bool, isAssetFavorited: Bool) {
        contentViewContainer.updateFavoriteAndNotificationButtons(isAssetPriceAlertEnabled: isAssetPriceAlertEnabled, isAssetFavorited: isAssetFavorited)
    }
    
    func updateChart(with data: ChartViewData) {
        lastBoundChartData = data
        contentViewContainer.updateChart(with: data)
    }
}
