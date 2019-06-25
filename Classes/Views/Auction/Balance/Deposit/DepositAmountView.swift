//
//  DepositAmountView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 20.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class DepositAmountView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleLabelTopInset: CGFloat = 20.0
        let horizontalInset: CGFloat = 20.0
        let fieldContainerSize = CGSize(width: 255.0, height: 48.0)
        let fieldContainerTopInset: CGFloat = 8.0
        let fieldContainerBottomInset: CGFloat = 24.0
        let fieldHorizontalInset: CGFloat = 15.0
        let fieldLeadingInset: CGFloat = 10.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var titleLabelView: DepositTransactionHeaderView = {
        let view = DepositTransactionHeaderView()
        view.titleLabel.text = "deposit-amount-view-title".localized
        view.titleLabel.textColor = SharedColors.darkGray
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var amountTitleLabel = {
        UILabel()
            .withAlignment(.center)
            .withLine(.single)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 13.0)))
            .withText("deposit-amount-title".localized)
    }()
    
    private lazy var fieldContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 6.0
        view.layer.borderWidth = 1.0
        view.layer.borderColor = SharedColors.softGray.cgColor
        return view
    }()
    
    private lazy var dollarLabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(.black)
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 15.0)))
            .withText("$")
    }()
    
    private(set) lazy var amountTextField: CursorlessTextField = {
        let view = CursorlessTextField()
        view.textAlignment = .right
        view.textColor = SharedColors.black
        view.attributedPlaceholder = NSAttributedString(
            string: "0,00",
            attributes: [NSAttributedString.Key.foregroundColor: SharedColors.softGray,
                         NSAttributedString.Key.font: UIFont.font(.overpass, withWeight: .bold(size: 15.0))]
        )
        view.font = UIFont.font(.overpass, withWeight: .bold(size: 15.0))
        view.keyboardType = .numberPad
        return view
    }()
    
    // MARK: Setup
    
    override func linkInteractors() {
        amountTextField.delegate = self
    }
    
    override func setListeners() {
        amountTextField.addTarget(self, action: #selector(didChangeText(_:)), for: .editingChanged)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupTitleLabelViewLayout()
        setupContainerViewLayout()
        setupAmountTitleLabelLayout()
        setupFieldContainerViewLayout()
        setupDollarLabelLayout()
        setupAmountTextFieldLayout()
        
        addDoneButtonOnKeyboard()
    }
    
    private func setupTitleLabelViewLayout() {
        addSubview(titleLabelView)
        
        titleLabelView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
    }
    
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(titleLabelView.snp.bottom)
        }
    }
    
    private func setupAmountTitleLabelLayout() {
        containerView.addSubview(amountTitleLabel)
        
        amountTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.titleLabelTopInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupFieldContainerViewLayout() {
        containerView.addSubview(fieldContainerView)
        
        fieldContainerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(layout.current.fieldContainerBottomInset)
            make.size.equalTo(layout.current.fieldContainerSize)
            make.centerX.equalToSuperview()
            make.top.equalTo(amountTitleLabel.snp.bottom).offset(layout.current.fieldContainerTopInset)
        }
    }
    
    private func setupDollarLabelLayout() {
        fieldContainerView.addSubview(dollarLabel)
        
        dollarLabel.setContentHuggingPriority(.required, for: .horizontal)
        dollarLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        dollarLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.fieldHorizontalInset)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupAmountTextFieldLayout() {
        fieldContainerView.addSubview(amountTextField)
        
        amountTextField.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.fieldHorizontalInset)
            make.leading.equalTo(dollarLabel.snp.trailing).offset(layout.current.fieldLeadingInset)
            make.centerY.equalToSuperview()
        }
    }
    
    private func addDoneButtonOnKeyboard() {
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(
            title: "title-done-lowercased".localized,
            style: .done,
            target: self,
            action: #selector(doneButtonAction)
        )
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        amountTextField.inputAccessoryView = doneToolbar
    }
    
    // MARK: Actions
    
    @objc
    private func didChangeText(_ textField: UITextField) {
        guard let doubleValueString = textField.text?.depositAmountFormatter() else {
            fieldContainerView.layer.borderColor = SharedColors.softGray.cgColor
            return
        }
        
        fieldContainerView.layer.borderColor = SharedColors.blue.cgColor
        
        textField.text = doubleValueString
    }
    
    @objc
    private func doneButtonAction() {
        amountTextField.resignFirstResponder()
    }
}

// MARK: TextFieldDelegate

extension DepositAmountView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        guard let doubleValueString = text.appending(string).currencyBidInputFormatting(),
            doubleValueString.doubleForSendSeparator != nil else {
                return false
        }
        
        return true
    }
}
