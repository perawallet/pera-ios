//
//  TransactionHistoryHeaderView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class TransactionHistoryHeaderView: BaseView {

    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: TransactionHistoryHeaderViewDelegate?
    
    private lazy var topImageView = UIImageView(image: img("modal-top-icon"))
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withAlignment(.left)
            .withFont(UIFont.font(withWeight: .medium(size: 16.0)))
            .withTextColor(SharedColors.primaryText)
            .withText("contacts-transactions-title".localized)
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .custom).withImage(img("icon-share-white", isTemplate: true))
        button.tintColor = SharedColors.gray600
        return button
    }()
    
    private(set) lazy var filterButton: UIButton = {
        UIButton(type: .custom).withImage(img("icon-transaction-filter"))
    }()
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
        layer.cornerRadius = 20.0
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    override func setListeners() {
        filterButton.addTarget(self, action: #selector(notifyDelegateToOpenFilterOptions), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(notifyDelegateToShareHistory), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupTopImageViewLayout()
        setupShareButtonLayout()
        setupFilterButtonLayout()
        setupTitleLabelLayout()
        setupSeparatorViewLayout()
    }
}

extension TransactionHistoryHeaderView {
    @objc
    private func notifyDelegateToOpenFilterOptions() {
        delegate?.transactionHistoryHeaderViewDidOpenFilterOptions(self)
    }
    
    @objc
    private func notifyDelegateToShareHistory() {
        delegate?.transactionHistoryHeaderViewDidShareHistory(self)
    }
}

extension TransactionHistoryHeaderView {
    private func setupTopImageViewLayout() {
        addSubview(topImageView)
        
        topImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
        }
    }
    
    private func setupShareButtonLayout() {
        addSubview(shareButton)
        
        shareButton.snp.makeConstraints { make in
            make.size.equalTo(layout.current.buttonSize)
            make.trailing.equalToSuperview().inset(layout.current.trailingInset)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupFilterButtonLayout() {
        addSubview(filterButton)
        
        filterButton.snp.makeConstraints { make in
            make.size.equalTo(layout.current.buttonSize)
            make.trailing.equalTo(shareButton.snp.leading)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.trailing.equalTo(filterButton.snp.leading)
            make.centerY.equalToSuperview()
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

extension TransactionHistoryHeaderView {
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setFilterImage(_ image: UIImage?) {
        filterButton.setImage(image, for: .normal)
    }
}

extension TransactionHistoryHeaderView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 8.0
        let horizontalInset: CGFloat = 20.0
        let buttonSize = CGSize(width: 40.0, height: 40.0)
        let trailingInset: CGFloat = 16.0
        let separatorHeight: CGFloat = 1.0
    }
}

protocol TransactionHistoryHeaderViewDelegate: class {
    func transactionHistoryHeaderViewDidOpenFilterOptions(_ transactionHistoryHeaderView: TransactionHistoryHeaderView)
    func transactionHistoryHeaderViewDidShareHistory(_ transactionHistoryHeaderView: TransactionHistoryHeaderView)
}
