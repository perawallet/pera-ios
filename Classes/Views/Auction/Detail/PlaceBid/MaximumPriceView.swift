//
//  MaximumPriceView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol MaximumPriceViewDelegate: class {
    
    func maximumPriceViewDidTypeInput(_ maximumPriceView: MaximumPriceView, in textField: UITextField)
}

class MaximumPriceView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleHorizontalInset: CGFloat = 17.0
        let titleTopInset: CGFloat = 18.0
        let separatorInset: CGFloat = 38.0
        let separatorHeight: CGFloat = 1.0
        let verticalSeparatorTopInset: CGFloat = 10.0
        let verticalSeparatorHeight: CGFloat = 30.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let borderColor = rgba(0.67, 0.67, 0.72, 0.3)
        static let separatorColor = rgb(0.95, 0.96, 0.96)
    }
    
    // MARK: Components
    
    private lazy var maxPriceTitleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(SharedColors.darkGray)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 12.0)))
            .withText("auction-detail-max-price".localized)
    }()
    
    private lazy var verticalSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    private(set) lazy var priceAmountTextField: CursorlessTextField = {
        let view = CursorlessTextField()
        view.textAlignment = .right
        view.textColor = SharedColors.turquois
        view.font = UIFont.font(.overpass, withWeight: .semiBold(size: 12.0))
        view.keyboardType = .numberPad
        view.delegate = self
        return view
    }()
    
    weak var delegate: MaximumPriceViewDelegate?
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
        
        layer.cornerRadius = 5.0
        layer.borderWidth = 1.0
        layer.borderColor = Colors.borderColor.cgColor
    }
    
    override func linkInteractors() {
        priceAmountTextField.delegate = self
    }
    
    override func setListeners() {
        priceAmountTextField.addTarget(self, action: #selector(didChangeText(_:)), for: .editingChanged)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupBidAmountTitleLabelLayout()
        setupVerticalSeparatorViewLayout()
        setupPriceAmountTextFieldLayout()
    }
    
    private func setupBidAmountTitleLabelLayout() {
        addSubview(maxPriceTitleLabel)
        
        maxPriceTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.titleHorizontalInset)
            make.top.equalToSuperview().inset(layout.current.titleTopInset)
        }
        
        maxPriceTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        maxPriceTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    private func setupVerticalSeparatorViewLayout() {
        addSubview(verticalSeparatorView)
        
        verticalSeparatorView.snp.makeConstraints { make in
            make.leading.equalTo(maxPriceTitleLabel.snp.trailing).offset(layout.current.separatorInset)
            make.width.equalTo(layout.current.separatorHeight)
            make.height.equalTo(layout.current.verticalSeparatorHeight)
            make.top.equalToSuperview().inset(layout.current.verticalSeparatorTopInset)
        }
    }
    
    private func setupPriceAmountTextFieldLayout() {
        addSubview(priceAmountTextField)
        
        priceAmountTextField.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.titleHorizontalInset)
            make.top.equalToSuperview().inset(layout.current.titleTopInset)
            make.leading.equalTo(verticalSeparatorView.snp.trailing).offset(layout.current.verticalSeparatorTopInset)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func didChangeText(_ textField: UITextField) {
        guard let doubleValueString = textField.text?.currencyBidInputFormatting(),
            let doubleValue = doubleValueString.doubleForSendSeparator,
            doubleValue <= Double(maximumMicroAlgos) else {
                return
        }
        
        textField.text = doubleValueString
        delegate?.maximumPriceViewDidTypeInput(self, in: textField)
    }
}

// MARK: - TextFieldDelegate
extension MaximumPriceView: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        guard let doubleValueString = text.appending(string).currencyBidInputFormatting(),
            let doubleValue = doubleValueString.doubleForSendSeparator,
            doubleValue <= Double(maximumMicroAlgos) else {
                return false
        }
        
        if range.location + range.length < text.count {
            return false
        } else {
            return true
        }
    }
}
