//
//  TransactionStatusView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 8.05.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class TransactionStatusView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var imageView = UIImageView()
    
    private lazy var statusLabel: UILabel = {
        UILabel().withFont(UIFont.font(withWeight: .bold(size: 12.0))).withAlignment(.center)
    }()
    
    override func configureAppearance() {
        layer.cornerRadius = 14.0
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        setupImageViewLayout()
        setupStatusLabelLayout()
    }
}

extension TransactionStatusView {
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.leadingInset)
            make.size.equalTo(layout.current.imageSize)
            make.top.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupStatusLabelLayout() {
        addSubview(statusLabel)
        
        statusLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(layout.current.labelLeadingInset)
            make.trailing.equalToSuperview().inset(layout.current.trailingInset)
            make.centerY.equalTo(imageView)
        }
    }
}

extension TransactionStatusView {
    func setStatus(_ status: Transaction.Status) {
        statusLabel.text = status.rawValue
        
        switch status {
        case .completed:
            imageView.image = img("icon-check")
            statusLabel.textColor = SharedColors.tertiaryText
            backgroundColor = SharedColors.primary.withAlphaComponent(0.1)
        case .pending:
            imageView.image = img("icon-pending")
            statusLabel.textColor = SharedColors.yellow700
            backgroundColor = SharedColors.yellow600.withAlphaComponent(0.1)
        case .failed:
            imageView.image = img("icon-failed-red")
            statusLabel.textColor = SharedColors.red
            backgroundColor = SharedColors.red.withAlphaComponent(0.1)
        }
    }
}

extension TransactionStatusView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let leadingInset: CGFloat = 8.0
        let imageSize = CGSize(width: 20.0, height: 20.0)
        let verticalInset: CGFloat = 4.0
        let labelLeadingInset: CGFloat = 4.0
        let trailingInset: CGFloat = 12.0
    }
}
