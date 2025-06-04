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

//   ChartSegmentedControl.swift

import UIKit

class ChartSegmentedControl: UIStackView {

    private(set) var buttons: [UIButton] = []
    private var segments: [ChartDataPeriod] = ChartDataPeriod.allCases
    
    var selectedSegment: ChartDataPeriod = .oneWeek {
        didSet {
            updateSelection()
            selectionChanged?(selectedSegment)
        }
    }

    var selectionChanged: ((ChartDataPeriod) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        axis = .horizontal
        distribution = .fillEqually
        spacing = 16

        for segment in segments {
            let button = UIButton(type: .system)
            button.setTitle(segment.title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            button.layer.cornerRadius = 8
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            buttons.append(button)
            addArrangedSubview(button)
        }

        updateSelection()
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        guard let index = buttons.firstIndex(of: sender) else { return }
        selectedSegment = segments[index]
    }

    private func updateSelection() {
        for (index, button) in buttons.enumerated() {
            let isSelected = segments[index] == selectedSegment
            button.backgroundColor = isSelected ? UIColor.systemGray6 : .clear
            button.setTitleColor(isSelected ? .black : .gray, for: .normal)
        }
    }
}
