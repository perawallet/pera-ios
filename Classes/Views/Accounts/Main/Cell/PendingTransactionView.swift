//
//  PendingTransactionView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PendingTransactionView: TransactionHistoryContextView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 25.0
        let spinnerSize = CGSize(width: 22.0, height: 22.0)
        let titleLabelInset: CGFloat = 65.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var pendingSpinnerView = LoadingSpinnerView()
    
    override func prepareLayout() {
        super.prepareLayout()
        
        adjustTitleLabelLayout()
        setupPendingSpinnerViewLayout()
        
        pendingSpinnerView.show()
    }
    
    private func adjustTitleLabelLayout() {
        titleLabel.snp.updateConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.titleLabelInset)
        }
    }
    
    private func setupPendingSpinnerViewLayout() {
        addSubview(pendingSpinnerView)
        
        pendingSpinnerView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.size.equalTo(layout.current.spinnerSize)
        }
    }
}
