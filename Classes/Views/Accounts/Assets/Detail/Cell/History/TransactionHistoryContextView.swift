//
//  TransactionHistoryContextView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class TransactionHistoryContextView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var contactLabel: UILabel = {
        let label = UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.primary)
        label.isHidden = true
        return label
    }()
    
    private(set) lazy var addressLabel: UILabel = {
        let label = UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.Text.primary)
        label.lineBreakMode = .byTruncatingMiddle
        label.isHidden = true
        return label
    }()
    
    private(set) lazy var transactionAmountView = TransactionAmountView()
    
    private(set) lazy var subtitleLabel: UILabel = {
        let label = UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .regular(size: 12.0)))
            .withTextColor(Colors.Text.secondary)
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    
    private(set) lazy var dateLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.right)
            .withFont(UIFont.font(withWeight: .regular(size: 12.0)))
            .withTextColor(Colors.Text.secondary)
    }()
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.secondary
    }
    
    override func prepareLayout() {
        setupContactNameLabelLayout()
        setupAddressLabelLayout()
        setupTransactionAmountViewLayout()
        setupSubtitleLabelLayout()
        setupDateLabelLayout()
        setupSeparatorViewLayout()
    }
}

extension TransactionHistoryContextView {
    private func setupContactNameLabelLayout() {
        addSubview(contactLabel)
        
        contactLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        contactLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        contactLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupAddressLabelLayout() {
        addSubview(addressLabel)
        
        addressLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addressLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        addressLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupTransactionAmountViewLayout() {
        addSubview(transactionAmountView)
        
        transactionAmountView.setContentCompressionResistancePriority(.required, for: .horizontal)
        transactionAmountView.setContentHuggingPriority(.required, for: .horizontal)
        
        transactionAmountView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset).priority(.required)
            make.top.equalToSuperview().inset(layout.current.verticalInset)
            make.centerY.equalTo(contactLabel)
            make.leading.greaterThanOrEqualTo(contactLabel.snp.trailing).offset(layout.current.minimumHorizontalSpacing).priority(.required)
        }
    }
    
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(contactLabel)
            make.top.equalTo(contactLabel.snp.bottom).offset(layout.current.labelVerticalInset)
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupDateLabelLayout() {
        addSubview(dateLabel)
        
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset).priority(.required)
            make.centerY.equalTo(subtitleLabel)
            make.leading.greaterThanOrEqualTo(subtitleLabel.snp.trailing)
                .offset(layout.current.minimumHorizontalSpacing)
                .priority(.required)
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension TransactionHistoryContextView {
    func setAddress(_ address: String?) {
        contactLabel.isHidden = true
        addressLabel.isHidden = false
        
        addressLabel.text = address.shortAddressDisplay()
    }
    
    func setContact(_ contact: String?) {
        contactLabel.isHidden = false
        addressLabel.isHidden = true
        contactLabel.text = contact
    }
    
    func reset() {
        contactLabel.text = nil
        addressLabel.text = nil
        contactLabel.isHidden = true
        addressLabel.isHidden = true
    }
}

extension TransactionHistoryContextView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 16.0
        let labelVerticalInset: CGFloat = 4.0
        let separatorHeight: CGFloat = 1.0
        let minimumHorizontalSpacing: CGFloat = 3.0
    }
}
