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
//  LedgerTutorialNumberView.swift

import UIKit

class LedgerTutorialNumberView: BaseView {
    
    private lazy var numberLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withAlignment(.center)
            .withTextColor(Colors.Text.tertiary)
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.LedgerTutorialNumber.background
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupNumberLabelLayout()
    }
}

extension LedgerTutorialNumberView {
    private func setupNumberLabelLayout() {
        addSubview(numberLabel)
        
        numberLabel.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }
    }
}

extension LedgerTutorialNumberView {
    func setCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
    }
    
    func setNumber(_ number: Int) {
        numberLabel.text = "\(number)"
    }
}

extension Colors {
    fileprivate enum LedgerTutorialNumber {
        static let background = color("ledgerTutorialNumberBackground")
    }
}
