//
//  BidAmountView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol BidAmountViewDelegate: class {
    
    func bidAmountView(_ bidAmountView: BidAmountView, didChange value: Float)
    func bidAmountViewDidTypeInput(_ bidAmountView: BidAmountView, in textField: UITextField)
}

class BidAmountView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let titleHorizontalInset: CGFloat = 17.0
        let titleTopInset: CGFloat = 18.0
        let fieldHorizontalInset: CGFloat = 11.0
        let fieldHeight: CGFloat = 31.0
        let amountLabelInset: CGFloat = 3.0
        let separatorInset: CGFloat = 12.0
        let separatorHeight: CGFloat = 1.0
        let sliderTopInset: CGFloat = 5.0
        let sliderHeight: CGFloat = 100.0
        let separatorTopInset: CGFloat = 8.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let borderColor = rgba(0.67, 0.67, 0.72, 0.3)
        static let separatorColor = rgb(0.95, 0.96, 0.96)
    }
    
    // MARK: Components
    
    private lazy var bidAmountTitleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withLine(.single)
            .withTextColor(SharedColors.darkGray)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 13.0)))
            .withText("auction-detail-bid-amount".localized)
    }()
    
    private(set) lazy var bidAmountTextField: CursorlessTextField = {
        let view = CursorlessTextField()
        view.textAlignment = .right
        view.textColor = SharedColors.turquois
        view.font = UIFont.font(.overpass, withWeight: .bold(size: 13.0))
        view.keyboardType = .numberPad
        view.layer.cornerRadius = 5.0
        view.layer.borderWidth = 1.0
        view.layer.borderColor = Colors.borderColor.cgColor
        view.backgroundColor = SharedColors.warmWhite
        
        return view
    }()
    
    private(set) lazy var availableAmountLabel: UILabel = {
        UILabel()
            .withAlignment(.right)
            .withLine(.single)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 13.0)))
    }()
    
    private lazy var horizontalSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    private(set) lazy var auctionSliderView: AuctionSliderView = {
        let view = AuctionSliderView()
        return view
    }()
    
    weak var delegate: BidAmountViewDelegate?
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
        
        layer.cornerRadius = 5.0
        layer.borderWidth = 1.0
        layer.borderColor = Colors.borderColor.cgColor
    }
    
    override func linkInteractors() {
        bidAmountTextField.delegate = self
        bidAmountTextField.cursorlessTextFieldDelegate = self
        auctionSliderView.delegate = self
    }
    
    override func setListeners() {
        bidAmountTextField.addTarget(self, action: #selector(didChangeText(_:)), for: .editingChanged)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupBidAmountTitleLabelLayout()
        setupBidAmountTextFieldLayout()
        setupAvailableAmountLabelLayout()
        setupHorizontalSeparatorViewLayout()
        setupAuctionSliderViewLayout()
        
        addDoneButtonOnKeyboard()
    }
    
    private func setupBidAmountTitleLabelLayout() {
        addSubview(bidAmountTitleLabel)
        
        bidAmountTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.titleHorizontalInset)
            make.top.equalToSuperview().inset(layout.current.titleTopInset)
        }
        
        bidAmountTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        bidAmountTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private func setupBidAmountTextFieldLayout() {
        addSubview(bidAmountTextField)
        
        bidAmountTextField.snp.makeConstraints { make in
            make.leading.equalTo(bidAmountTitleLabel.snp.trailing).offset(layout.current.titleHorizontalInset)
            make.top.equalToSuperview().inset(layout.current.fieldHorizontalInset)
            make.height.equalTo(layout.current.fieldHeight)
        }
        
        bidAmountTextField.setRightPadding(amount: 5.0)
    }
    
    private func setupAvailableAmountLabelLayout() {
        addSubview(availableAmountLabel)
        
        availableAmountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.titleHorizontalInset)
            make.leading.equalTo(bidAmountTextField.snp.trailing).offset(layout.current.amountLabelInset)
            make.top.equalToSuperview().inset(layout.current.titleTopInset)
        }
        
        availableAmountLabel.setContentHuggingPriority(.required, for: .horizontal)
        availableAmountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private func setupHorizontalSeparatorViewLayout() {
        addSubview(horizontalSeparatorView)
        
        horizontalSeparatorView.snp.makeConstraints { make in
            make.top.equalTo(bidAmountTextField.snp.bottom).offset(layout.current.separatorTopInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.separatorInset)
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
    
    private func setupAuctionSliderViewLayout() {
        addSubview(auctionSliderView)
        
        auctionSliderView.snp.makeConstraints { make in
            make.top.equalTo(horizontalSeparatorView.snp.bottom)
            make.height.equalTo(layout.current.sliderHeight)
            make.leading.trailing.bottom.equalToSuperview()
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
        
        bidAmountTextField.inputAccessoryView = doneToolbar
    }
    
    // MARK: Actions
    
    @objc
    private func didChangeText(_ textField: UITextField) {
        guard let doubleValueString = textField.text?.currencyBidInputFormatting(),
            let doubleValue = doubleValueString.doubleForSendSeparator(with: 6),
            doubleValue <= Double(maximumMicroAlgos) else {
                return
        }
        
        textField.text = doubleValueString
        delegate?.bidAmountViewDidTypeInput(self, in: textField)
    }
    
    @objc
    private func doneButtonAction() {
        bidAmountTextField.resignFirstResponder()
    }
}
// MARK: AuctionSliderViewDelegate

extension BidAmountView: AuctionSliderViewDelegate {

    func auctionSliderView(_ auctionSliderView: AuctionSliderView, didChange value: Float) {
        delegate?.bidAmountView(self, didChange: value)
    }
}

// MARK: - TextFieldDelegate

extension BidAmountView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        
        guard let doubleValueString = text.appending(string).currencyBidInputFormatting(),
            let doubleValue = doubleValueString.doubleForSendSeparator(with: 6),
            let availableAmountString = availableAmountLabel.text?.currencyBidInputFormatting(),
            let availableAmount = availableAmountString.doubleForSendSeparator(with: 6),
            doubleValue <= availableAmount else {
                return false
        }
        
        return true
    }
}

// MARK: - CursorlessTextFieldDelegate

extension BidAmountView: CursorlessTextFieldDelegate {
    
    func cursorlessTextFieldDidDeleteBackward(_ cursorlessTextField: CursorlessTextField) {
        if let text = cursorlessTextField.text {
            if !text.isEmpty {
                return
            }
            setPlaceholderStringAsText(to: cursorlessTextField)
        } else {
            setPlaceholderStringAsText(to: cursorlessTextField)
        }
    }
    
    private func setPlaceholderStringAsText(to textField: CursorlessTextField) {
        guard let placeholderString = textField.attributedPlaceholder?.string else {
            return
        }
        
        if !placeholderString.isEmpty {
            if let formattedValue = String(placeholderString.dropLast(1)).currencyBidInputFormatting() {
                textField.text = formattedValue
            }
        }
    }
}
