//
//  NumpadView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class NumpadView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: NumpadViewDelegate?
    
    private lazy var firstRowStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = layout.current.stackViewSpacing
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    private lazy var numberOneButton = NumpadButton(numpadValue: .number("1"))
    
    private lazy var numberTwoButton = NumpadButton(numpadValue: .number("2"))
    
    private lazy var numberThreeButton = NumpadButton(numpadValue: .number("3"))
    
    private lazy var secondRowStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = layout.current.stackViewSpacing
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    private lazy var numberFourButton = NumpadButton(numpadValue: .number("4"))
    
    private lazy var numberFiveButton = NumpadButton(numpadValue: .number("5"))
    
    private lazy var numberSixButton = NumpadButton(numpadValue: .number("6"))
    
    private lazy var thirdRowStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = layout.current.stackViewSpacing
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    private lazy var numberSevenButton = NumpadButton(numpadValue: .number("7"))
    
    private lazy var numberEightButton = NumpadButton(numpadValue: .number("8"))
    
    private lazy var numberNineButton = NumpadButton(numpadValue: .number("9"))
    
    private lazy var fourthRowStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = layout.current.stackViewSpacing
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    private lazy var spacingButton = NumpadButton(numpadValue: .spacing)
    
    private lazy var zeroButton = NumpadButton(numpadValue: .number("0"))
    
    private lazy var deleteButton = NumpadButton(numpadValue: .delete)
    
    override func configureAppearance() {
        backgroundColor = color("secondaryBackground")
    }
    
    override func linkInteractors() {
        numberOneButton.addTarget(self, action: #selector(notifyDelegateToAddNumpadValue), for: .touchUpInside)
        numberTwoButton.addTarget(self, action: #selector(notifyDelegateToAddNumpadValue), for: .touchUpInside)
        numberThreeButton.addTarget(self, action: #selector(notifyDelegateToAddNumpadValue), for: .touchUpInside)
        numberFourButton.addTarget(self, action: #selector(notifyDelegateToAddNumpadValue), for: .touchUpInside)
        numberFiveButton.addTarget(self, action: #selector(notifyDelegateToAddNumpadValue), for: .touchUpInside)
        numberSixButton.addTarget(self, action: #selector(notifyDelegateToAddNumpadValue), for: .touchUpInside)
        numberSevenButton.addTarget(self, action: #selector(notifyDelegateToAddNumpadValue), for: .touchUpInside)
        numberEightButton.addTarget(self, action: #selector(notifyDelegateToAddNumpadValue), for: .touchUpInside)
        numberNineButton.addTarget(self, action: #selector(notifyDelegateToAddNumpadValue), for: .touchUpInside)
        zeroButton.addTarget(self, action: #selector(notifyDelegateToAddNumpadValue), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(notifyDelegateToAddNumpadValue), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupFirstRowStackViewLayout()
        setupSecondRowStackViewLayout()
        setupThirdRowStackViewLayout()
        setupFourthRowStackViewLayout()
    }
}

extension NumpadView {
    @objc
    private func notifyDelegateToAddNumpadValue(sender: NumpadButton) {
        delegate?.numpadView(self, didSelect: sender.numpadValue)
    }
}

extension NumpadView {
    private func setupFirstRowStackViewLayout() {
        addSubview(firstRowStackView)
        
        firstRowStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(layout.current.stackViewHeight)
            make.centerX.equalToSuperview()
        }
        
        firstRowStackView.addArrangedSubview(numberOneButton)
        firstRowStackView.addArrangedSubview(numberTwoButton)
        firstRowStackView.addArrangedSubview(numberThreeButton)
    }
    
    private func setupSecondRowStackViewLayout() {
        addSubview(secondRowStackView)
        
        secondRowStackView.snp.makeConstraints { make in
            make.top.equalTo(firstRowStackView.snp.bottom).offset(layout.current.stackViewSpacing)
            make.height.equalTo(layout.current.stackViewHeight)
            make.centerX.equalToSuperview()
        }
        
        secondRowStackView.addArrangedSubview(numberFourButton)
        secondRowStackView.addArrangedSubview(numberFiveButton)
        secondRowStackView.addArrangedSubview(numberSixButton)
    }
    
    private func setupThirdRowStackViewLayout() {
        addSubview(thirdRowStackView)
        
        thirdRowStackView.snp.makeConstraints { make in
            make.top.equalTo(secondRowStackView.snp.bottom).offset(layout.current.stackViewSpacing)
            make.height.equalTo(layout.current.stackViewHeight)
            make.centerX.equalToSuperview()
        }
        
        thirdRowStackView.addArrangedSubview(numberSevenButton)
        thirdRowStackView.addArrangedSubview(numberEightButton)
        thirdRowStackView.addArrangedSubview(numberNineButton)
    }
    
    private func setupFourthRowStackViewLayout() {
        addSubview(fourthRowStackView)
        
        fourthRowStackView.snp.makeConstraints { make in
            make.top.equalTo(thirdRowStackView.snp.bottom).offset(layout.current.stackViewSpacing)
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.stackViewHeight)
            make.centerX.equalToSuperview()
        }
        
        fourthRowStackView.addArrangedSubview(spacingButton)
        fourthRowStackView.addArrangedSubview(zeroButton)
        fourthRowStackView.addArrangedSubview(deleteButton)
    }
}

extension NumpadView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let stackViewSpacing: CGFloat = 24.0 * verticalScale
        let stackViewHeight: CGFloat = 72.0 * verticalScale
    }
}

protocol NumpadViewDelegate: class {
    func numpadView(_ numpadView: NumpadView, didSelect value: NumpadValue)
}

enum NumpadValue {
    case spacing
    case number(String)
    case delete
}
