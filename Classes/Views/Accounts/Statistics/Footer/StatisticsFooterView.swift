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
//   StatisticsFooterView.swift

import Macaroon
import UIKit

final class StatisticsFooterView: View {
    private lazy var titleLabel = UILabel()
    private lazy var last24hVolumeInfoView = StatisticsInfoView()
    private lazy var marketCapInfoView = StatisticsInfoView()
    private lazy var previousCloseVolumeInfoView = StatisticsInfoView()
    private lazy var openInfoView = StatisticsInfoView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(StatisticsFooterViewTheme())
    }

    func customize(_ theme: StatisticsFooterViewTheme) {
        addTitleLabel(theme)
        addLast24hVolumeInfoView(theme)
        addMarketCapInfoView(theme)
        addPreviousCloseVolumeInfoView(theme)
        addOpenInfoView(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension StatisticsFooterView {
    private func addTitleLabel(_ theme: StatisticsFooterViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
    }

    private func addLast24hVolumeInfoView(_ theme: StatisticsFooterViewTheme) {
        addSubview(last24hVolumeInfoView)
        last24hVolumeInfoView.snp.makeConstraints {
            $0.top == titleLabel.snp.bottom + theme.infoViewPaddings.top
            $0.leading == 0
            $0.fitToWidth(theme.infoViewWidth)
        }
    }

    private func addMarketCapInfoView(_ theme: StatisticsFooterViewTheme) {
        addSubview(marketCapInfoView)
        marketCapInfoView.snp.makeConstraints {
            $0.top == last24hVolumeInfoView
            $0.leading == last24hVolumeInfoView.snp.trailing + theme.infoViewPaddings.leading
            $0.trailing.lessThanOrEqualToSuperview()
            $0.width == last24hVolumeInfoView
        }
    }

    private func addPreviousCloseVolumeInfoView(_ theme: StatisticsFooterViewTheme) {
        addSubview(previousCloseVolumeInfoView)
        previousCloseVolumeInfoView.snp.makeConstraints {
            $0.top == last24hVolumeInfoView.snp.bottom + theme.infoViewPaddings.top
            $0.leading == 0
            $0.width == last24hVolumeInfoView
            $0.bottom.equalToSuperview()
        }
    }

    private func addOpenInfoView(_ theme: StatisticsFooterViewTheme) {
        addSubview(openInfoView)
        openInfoView.snp.makeConstraints {
            $0.top == previousCloseVolumeInfoView
            $0.leading == previousCloseVolumeInfoView.snp.trailing + theme.infoViewPaddings.leading
            $0.trailing.lessThanOrEqualToSuperview()
            $0.width == last24hVolumeInfoView
            $0.bottom.equalToSuperview()
        }
    }
}

extension StatisticsFooterView {
    func bindData(_ viewModel: StatisticsFooterViewModel) {
        last24hVolumeInfoView.bindData(viewModel.last24hVolumeViewModel)
        marketCapInfoView.bindData(viewModel.marketCapViewModel)
        previousCloseVolumeInfoView.bindData(viewModel.previousCloseViewModel)
        openInfoView.bindData(viewModel.openViewModel)
    }
}
