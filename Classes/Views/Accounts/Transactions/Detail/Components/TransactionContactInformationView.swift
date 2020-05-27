//
//  TransactionContactInformationView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class TransactionContactInformationView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: TransactionContactInformationViewDelegate?
    
    private lazy var titleLabel = TransactionDetailTitleLabel()
    
    private(set) lazy var contactDisplayView = ContactDisplayView()
    
    private lazy var separatorView = LineSeparatorView()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func linkInteractors() {
        contactDisplayView.delegate = self
    }
    
    override func prepareLayout() {
        setupTitleLabelLayout()
        setupContactDisplayViewLayout()
        setupSeparatorViewLayout()
    }
}

extension TransactionContactInformationView {
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.labelTopInset)
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupContactDisplayViewLayout() {
        addSubview(contactDisplayView)
        
        contactDisplayView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(layout.current.contactDisplayViewOffset)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(layout.current.contactDisplayViewOffset)
            make.trailing.equalToSuperview().inset(layout.current.horizontalInset)
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

extension TransactionContactInformationView {
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setContact(_ contact: Contact) {
        contactDisplayView.setContact(contact)
    }
    
    func setName(_ name: String) {
        contactDisplayView.setName(name)
    }
    
    func setQRAction() {
        contactDisplayView.setQRAction()
    }
    
    func setAddContactAction() {
        contactDisplayView.setAddContactAction()
    }
    
    func setContactImage(hidden: Bool) {
        contactDisplayView.setImage(hidden: hidden)
    }
}

extension TransactionContactInformationView: ContactDisplayViewDelegate {
    func contactDisplayViewDidTapActionButton(_ contactDisplayView: ContactDisplayView) {
        delegate?.transactionContactInformationViewDidTapActionButton(self)
    }
}

extension TransactionContactInformationView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let contactDisplayViewOffset: CGFloat = 10.0
        let labelTopInset: CGFloat = 20.0
        let separatorHeight: CGFloat = 1.0
    }
}

protocol TransactionContactInformationViewDelegate: class {
    func transactionContactInformationViewDidTapActionButton(_ transactionContactInformationView: TransactionContactInformationView)
}
