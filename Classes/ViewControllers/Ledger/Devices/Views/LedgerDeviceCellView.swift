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

//
//  LedgerDeviceView.swift

import MacaroonUIKit
import UIKit

final class LedgerDeviceCellView: View {
    private lazy var ledgerImageView = UIImageView()
    private lazy var deviceNameLabel = UILabel()
    private lazy var arrowImageView = UIImageView()

    func customize(_ theme: LedgerDeviceCellViewTheme) {
        drawAppearance(corner: theme.corner)
        drawAppearance(shadow: theme.shadow)

        addDeviceImageView(theme)
        addArrowImageView(theme)
        addDeviceNameLabel(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension LedgerDeviceCellView {
    private func addDeviceImageView(_ theme: LedgerDeviceCellViewTheme) {
        ledgerImageView.customizeAppearance(theme.ledgerImage)

        addSubview(ledgerImageView)
        ledgerImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.centerY.equalToSuperview()
            $0.fitToSize(theme.ledgerIconSize)
        }
    }

    private func addArrowImageView(_ theme: LedgerDeviceCellViewTheme) {
        arrowImageView.customizeAppearance(theme.arrowImage)

        addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.fitToSize(theme.arrowIconSize)
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
        }
    }

    private func addDeviceNameLabel(_ theme: LedgerDeviceCellViewTheme) {
        deviceNameLabel.customizeAppearance(theme.title)

        addSubview(deviceNameLabel)
        deviceNameLabel.snp.makeConstraints {
            $0.leading.equalTo(ledgerImageView.snp.trailing).offset(theme.horizontalInset)
            $0.trailing.lessThanOrEqualTo(arrowImageView.snp.leading).offset(-theme.horizontalInset)
            $0.centerY.equalTo(ledgerImageView)
        }
    }
}

extension LedgerDeviceCellView: ViewModelBindable {
    func bindData(_ viewModel: LedgerDeviceListViewModel?) {
        deviceNameLabel.text = viewModel?.ledgerName
    }
}
