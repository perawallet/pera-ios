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
//   AlgoStatisticsFooterView.swift

import MacaroonUIKit
import UIKit

final class AlgoStatisticsFooterView: View {
    private lazy var titleLabel = UILabel()
    private lazy var previousCloseVolumeInfoView = AlgoStatisticsInfoView()
    private lazy var openInfoView = AlgoStatisticsInfoView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(AlgoStatisticsFooterViewTheme())
    }

    func customize(_ theme: AlgoStatisticsFooterViewTheme) {
        addTitleLabel(theme)
        addPreviousCloseVolumeInfoView(theme)
        addOpenInfoView(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension AlgoStatisticsFooterView {
    private func addTitleLabel(_ theme: AlgoStatisticsFooterViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
    }

    private func addPreviousCloseVolumeInfoView(_ theme: AlgoStatisticsFooterViewTheme) {
        addSubview(previousCloseVolumeInfoView)
        previousCloseVolumeInfoView.snp.makeConstraints {
            $0.top == titleLabel.snp.bottom + theme.infoViewPaddings.top
            $0.leading == 0
            $0.fitToWidth(theme.infoViewWidth)
            $0.bottom.equalToSuperview()
        }
    }

    private func addOpenInfoView(_ theme: AlgoStatisticsFooterViewTheme) {
        addSubview(openInfoView)
        openInfoView.snp.makeConstraints {
            $0.top == previousCloseVolumeInfoView
            $0.leading == previousCloseVolumeInfoView.snp.trailing + theme.infoViewPaddings.leading
            $0.trailing.lessThanOrEqualToSuperview()
            $0.width == previousCloseVolumeInfoView
            $0.bottom.equalToSuperview()
        }
    }
}

extension AlgoStatisticsFooterView {
    func bindData(_ viewModel: AlgoStatisticsFooterViewModel) {
        previousCloseVolumeInfoView.bindData(viewModel.previousCloseViewModel)
        openInfoView.bindData(viewModel.openViewModel)
    }
}
