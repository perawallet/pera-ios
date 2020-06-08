//
//  TransactionTitleInformationView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class TransactionTitleInformationView: BaseView {
    
    weak var delegate: TransactionTitleInformationViewDelegate?
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var copyValueGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(notifyDelegateToCopyValue))
    
    private lazy var titleLabel = TransactionDetailTitleLabel()
    
    private lazy var detailLabel: UILabel = {
        let label = UILabel()
            .withFont(UIFont.font(withWeight: .medium(size: 14.0)))
            .withLine(.contained)
            .withAlignment(.left)
            .withTextColor(SharedColors.primaryText)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func linkInteractors() {
        detailLabel.addGestureRecognizer(copyValueGestureRecognizer)
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupDetailLabelLayout()
        setupSeparatorViewLayout()
    }
}

extension TransactionTitleInformationView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.verticalInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
            make.top.equalTo(titleLabel.snp.bottom).offset(layout.current.labelTopOffset)
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
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

extension TransactionTitleInformationView {
    @objc
    private func notifyDelegateToCopyValue(copyValueGestureRecognizer: UILongPressGestureRecognizer) {
        delegate?.transactionTitleInformationViewDidCopyDetail(self)
    }
}

extension TransactionTitleInformationView {
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setDetail(_ detail: String) {
        detailLabel.text = detail
    }
    
    func setSeparatorView(hidden: Bool) {
        separatorView.isHidden = hidden
    }
}

extension TransactionTitleInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let verticalInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 1.0
        let labelTopOffset: CGFloat = 8.0
    }
}

protocol TransactionTitleInformationViewDelegate: class {
    func transactionTitleInformationViewDidCopyDetail(_ transactionTitleInformationView: TransactionTitleInformationView)
}
