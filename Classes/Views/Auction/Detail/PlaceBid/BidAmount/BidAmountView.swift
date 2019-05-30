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
        let amountLabelInset: CGFloat = 3.0
        let separatorInset: CGFloat = 12.0
        let separatorHeight: CGFloat = 1.0
        let verticalSeparatorTopInset: CGFloat = 10.0
        let verticalSeparatorHeight: CGFloat = 30.0
        let sliderTopInset: CGFloat = 5.0
        let sliderHeight: CGFloat = 100.0
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
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0)))
            .withText("auction-detail-bid-amount".localized)
    }()
    
    private lazy var verticalSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.borderColor
        return view
    }()
    
    private(set) lazy var bidAmountTextField: CursorlessTextField = {
        let view = CursorlessTextField()
        view.textAlignment = .right
        view.textColor = SharedColors.blue
        view.font = UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0))
        view.keyboardType = .numberPad
        view.attributedPlaceholder = NSAttributedString(
            string: "$0.00",
            attributes: [NSAttributedString.Key.foregroundColor: SharedColors.darkGray,
                         NSAttributedString.Key.font: UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0))]
        )
        view.delegate = self
        
        return view
    }()
    
    private(set) lazy var availableAmountLabel: UILabel = {
        UILabel()
            .withAlignment(.right)
            .withLine(.single)
            .withTextColor(SharedColors.softGray)
            .withFont(UIFont.font(.montserrat, withWeight: .semiBold(size: 12.0)))
            .withText("/ $200,000.00")
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
        auctionSliderView.delegate = self
    }
    
    override func setListeners() {
        bidAmountTextField.addTarget(self, action: #selector(didChangeText(_:)), for: .editingChanged)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupBidAmountTitleLabelLayout()
        setupVerticalSeparatorViewLayout()
        setupBidAmountTextFieldLayout()
        setupAvailableAmountLabelLayout()
        setupHorizontalSeparatorViewLayout()
        setupAuctionSliderViewLayout()
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
    
    private func setupVerticalSeparatorViewLayout() {
        addSubview(verticalSeparatorView)
        
        verticalSeparatorView.snp.makeConstraints { make in
            make.leading.equalTo(bidAmountTitleLabel.snp.trailing).offset(layout.current.titleHorizontalInset)
            make.width.equalTo(layout.current.separatorHeight)
            make.height.equalTo(layout.current.verticalSeparatorHeight)
            make.top.equalToSuperview().inset(layout.current.verticalSeparatorTopInset)
        }
    }
    
    private func setupBidAmountTextFieldLayout() {
        addSubview(bidAmountTextField)
        
        bidAmountTextField.snp.makeConstraints { make in
            make.leading.equalTo(verticalSeparatorView.snp.trailing).offset(layout.current.amountLabelInset)
            make.top.equalToSuperview().inset(layout.current.titleTopInset)
        }
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
            make.top.equalTo(bidAmountTitleLabel.snp.bottom).offset(layout.current.titleHorizontalInset)
            make.leading.trailing.equalToSuperview().inset(layout.current.separatorInset)
            make.height.equalTo(layout.current.separatorHeight)
        }
    }
    
    private func setupAuctionSliderViewLayout() {
        addSubview(auctionSliderView)
        
        auctionSliderView.snp.makeConstraints { make in
            make.top.equalTo(horizontalSeparatorView.snp.bottom).offset(layout.current.sliderTopInset)
            make.height.equalTo(layout.current.sliderHeight)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: Actions
    
    @objc
    private func didChangeText(_ textField: UITextField) {
        delegate?.bidAmountViewDidTypeInput(self, in: textField)
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
