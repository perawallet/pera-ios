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

//   ChartTendencyView.swift

import UIKit
import MacaroonUIKit

final class ChartTendencyView: UIView {
    private let diffLabel = UILabel()
    private let percentLabel = UILabel()
    private let iconView = UIImageView()

    init() {
        super.init(frame: .zero)
        addSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(
        differenceText: TextProvider?,
        differenceInPercentageText: TextProvider?,
        arrowImageView: ImageProvider?,
        hideDiffLabel: Bool,
        baselineView: UIView
    ) {
        differenceText?.load(in: diffLabel)
        if let differenceInPercentageText {
            differenceInPercentageText.load(in: percentLabel)
            arrowImageView?.load(in: iconView)
        } else {
            percentLabel.text = nil
            iconView.image = nil
        }

        diffLabel.isHidden = hideDiffLabel
        setupConstraints(hideDiffLabel: hideDiffLabel, baselineView: baselineView)
    }

    private func addSubviews() {
        [diffLabel, iconView, percentLabel].forEach(addSubview)
    }

    private func setupConstraints(hideDiffLabel: Bool, baselineView: UIView) {
        [diffLabel, iconView, percentLabel].forEach { $0.snp.removeConstraints() }

        if hideDiffLabel {
            iconView.snp.makeConstraints {
                $0.leading.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
            percentLabel.snp.makeConstraints {
                $0.leading.equalTo(iconView.snp.trailing).offset(4)
                $0.centerY.equalTo(iconView)
                $0.trailing.equalToSuperview()
            }
        } else {
            diffLabel.snp.makeConstraints {
                $0.leading.equalToSuperview()
                $0.firstBaseline.equalTo(baselineView)
            }
            iconView.snp.makeConstraints {
                $0.leading.equalTo(diffLabel.snp.trailing).offset(10)
                $0.centerY.equalTo(diffLabel)
            }
            percentLabel.snp.makeConstraints {
                $0.leading.equalTo(iconView.snp.trailing).offset(4)
                $0.firstBaseline.equalTo(diffLabel)
                $0.trailing.equalToSuperview()
            }
        }
    }
}
