//
//  PendingTransactionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PendingTransactionView: TransactionHistoryContextView {
    
    private let layout = Layout<LayoutConstants>()
    
    private(set) lazy var pendingImageView = UIImageView(image: img("icon-pending"))
    
    override func prepareLayout() {
        super.prepareLayout()
        adjustTitleLabelLayout()
        setupPendingImageViewLayout()
    }
}

extension PendingTransactionView {
    private func adjustTitleLabelLayout() {
        contactLabel.snp.updateConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.titleLabelInset)
        }
        
        addressLabel.snp.updateConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.titleLabelInset)
        }
    }
    
    private func setupPendingImageViewLayout() {
        addSubview(pendingImageView)
        
        pendingImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.size.equalTo(layout.current.imageSize)
        }
    }
}

extension PendingTransactionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let imageSize = CGSize(width: 24.0, height: 24.0)
        let titleLabelInset: CGFloat = 56.0
    }
}
