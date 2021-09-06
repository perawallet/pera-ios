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
//  NumpadView.swift

import UIKit
import Macaroon

final class NumpadView: View {
    weak var delegate: NumpadViewDelegate?
    
    private lazy var firstRowStackView = UIStackView()
    private lazy var numberOneButton = NumpadButton(numpadKey: .number("1"))
    private lazy var numberTwoButton = NumpadButton(numpadKey: .number("2"))
    private lazy var numberThreeButton = NumpadButton(numpadKey: .number("3"))
    
    private lazy var secondRowStackView = UIStackView()
    private lazy var numberFourButton = NumpadButton(numpadKey: .number("4"))
    private lazy var numberFiveButton = NumpadButton(numpadKey: .number("5"))
    private lazy var numberSixButton = NumpadButton(numpadKey: .number("6"))
    
    private lazy var thirdRowStackView = UIStackView()
    private lazy var numberSevenButton = NumpadButton(numpadKey: .number("7"))
    private lazy var numberEightButton = NumpadButton(numpadKey: .number("8"))
    private lazy var numberNineButton = NumpadButton(numpadKey: .number("9"))
    
    private lazy var fourthRowStackView = UIStackView()
    private lazy var spacingButton = NumpadButton(numpadKey: .spacing)
    private lazy var zeroButton = NumpadButton(numpadKey: .number("0"))
    private lazy var deleteButton = NumpadButton(numpadKey: .delete)

    func customize(_ theme: NumpadViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        
        addFirstRowStackView(theme)
        addSecondRowStackView(theme)
        addThirdRowStackView(theme)
        addFourthRowStackView(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    func linkInteractors() {
        [
            numberOneButton, numberTwoButton, numberThreeButton,
            numberFourButton, numberFiveButton, numberSixButton,
            numberSevenButton, numberEightButton, numberNineButton,
            zeroButton, deleteButton
        ].forEach {
            $0.addTarget(self, action: #selector(notifyDelegateToAddNumpadValue), for: .touchUpInside)
        }
    }
}

extension NumpadView {
    @objc
    private func notifyDelegateToAddNumpadValue(sender: NumpadButton) {
        delegate?.numpadView(self, didSelect: sender.numpadKey)
    }
}

extension NumpadView {
    private func addFirstRowStackView(_ theme: NumpadViewTheme) {
        configureStackView(firstRowStackView, with: theme)

        addSubview(firstRowStackView)
        firstRowStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(theme.stackViewHeight)
            $0.centerX.equalToSuperview()
        }
        
        firstRowStackView.addArrangedSubview(numberOneButton)
        firstRowStackView.addArrangedSubview(numberTwoButton)
        firstRowStackView.addArrangedSubview(numberThreeButton)
    }
    
    private func addSecondRowStackView(_ theme: NumpadViewTheme) {
        configureStackView(secondRowStackView, with: theme)

        addSubview(secondRowStackView)
        secondRowStackView.snp.makeConstraints {
            $0.top.equalTo(firstRowStackView.snp.bottom).offset(theme.stackViewSpacing)
            $0.height.equalTo(theme.stackViewHeight)
            $0.centerX.equalToSuperview()
        }
        
        secondRowStackView.addArrangedSubview(numberFourButton)
        secondRowStackView.addArrangedSubview(numberFiveButton)
        secondRowStackView.addArrangedSubview(numberSixButton)
    }
    
    private func addThirdRowStackView(_ theme: NumpadViewTheme) {
        configureStackView(thirdRowStackView, with: theme)

        addSubview(thirdRowStackView)
        thirdRowStackView.snp.makeConstraints {
            $0.top.equalTo(secondRowStackView.snp.bottom).offset(theme.stackViewSpacing)
            $0.height.equalTo(theme.stackViewHeight)
            $0.centerX.equalToSuperview()
        }
        
        thirdRowStackView.addArrangedSubview(numberSevenButton)
        thirdRowStackView.addArrangedSubview(numberEightButton)
        thirdRowStackView.addArrangedSubview(numberNineButton)
    }
    
    private func addFourthRowStackView(_ theme: NumpadViewTheme) {
        configureStackView(fourthRowStackView, with: theme)

        addSubview(fourthRowStackView)
        fourthRowStackView.snp.makeConstraints {
            $0.top.equalTo(thirdRowStackView.snp.bottom).offset(theme.stackViewSpacing)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(theme.stackViewHeight)
            $0.centerX.equalToSuperview()
        }
        
        fourthRowStackView.addArrangedSubview(spacingButton)
        fourthRowStackView.addArrangedSubview(zeroButton)
        fourthRowStackView.addArrangedSubview(deleteButton)
    }
}

extension NumpadView {
    private func configureStackView(_ stackView: UIStackView, with theme: NumpadViewTheme) {
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = theme.stackViewSpacing
    }
}

protocol NumpadViewDelegate: AnyObject {
    func numpadView(_ numpadView: NumpadView, didSelect value: NumpadKey)
}

enum NumpadKey {
    case spacing
    case number(String)
    case delete
}
