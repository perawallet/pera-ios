//
//  TransactionHistoryContextView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class TransactionHistoryContextView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 25.0
        let topInset: CGFloat = 18.0
        let amountTopInset: CGFloat = 16.0
        let bottomInset: CGFloat = 18.0
        let labelVerticalInset: CGFloat = 3.0
        let separatorInset: CGFloat = 30.0
        let separatorHeight: CGFloat = 1.0
        let minimumHorizontalSpacing: CGFloat = 3.0
        let titleLabelRightInset: CGFloat = 125.0
        let amountViewHeight: CGFloat = 22.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgb(0.95, 0.96, 0.96)
    }
    
    // MARK: Components
    
    private(set) lazy var contactLabel: UILabel = {
        let label = UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 13.0)))
            .withTextColor(SharedColors.black)
        label.isHidden = true
        return label
    }()
    
    private(set) lazy var addressLabel: UILabel = {
        let label = UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(.avenir, withWeight: .demiBold(size: 13.0)))
            .withTextColor(SharedColors.black)
        label.lineBreakMode = .byTruncatingMiddle
        label.isHidden = true
        return label
    }()
    
    private(set) lazy var transactionAmountView: AlgosAmountView = {
        let view = AlgosAmountView()
        return view
    }()
    
    private(set) lazy var subtitleLabel: UILabel = {
        let label = UILabel()
            .withLine(.single)
            .withAlignment(.left)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 12.0)))
            .withTextColor(SharedColors.softGray)
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    
    private(set) lazy var dateLabel: UILabel = {
        UILabel()
            .withLine(.single)
            .withAlignment(.right)
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 12.0)))
            .withTextColor(SharedColors.darkGray)
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .white
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupContactNameLabelLayout()
        setupAddressLabelLayout()
        setupTransactionAmountViewLayout()
        setupSubtitleLabelLayout()
        setupDateLabelLayout()
        setupSeparatorViewLayout()
    }
    
    private func setupContactNameLabelLayout() {
        addSubview(contactLabel)
        
        contactLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        contactLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        contactLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupAddressLabelLayout() {
        addSubview(addressLabel)
        
        addressLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addressLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        addressLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupTransactionAmountViewLayout() {
        addSubview(transactionAmountView)
        
        transactionAmountView.setContentCompressionResistancePriority(.required, for: .horizontal)
        transactionAmountView.setContentHuggingPriority(.required, for: .horizontal)
        
        transactionAmountView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset).priority(.required)
            make.top.equalToSuperview().inset(layout.current.amountTopInset)
            make.centerY.equalTo(contactLabel)
            make.height.equalTo(layout.current.amountViewHeight)
            make.leading.greaterThanOrEqualTo(contactLabel.snp.trailing).offset(layout.current.minimumHorizontalSpacing).priority(.required)
        }
    }
    
    private func setupSubtitleLabelLayout() {
        addSubview(subtitleLabel)
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(contactLabel)
            make.top.equalTo(contactLabel.snp.bottom).offset(layout.current.labelVerticalInset)
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
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
            make.leading.trailing.equalToSuperview().inset(layout.current.separatorInset)
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
