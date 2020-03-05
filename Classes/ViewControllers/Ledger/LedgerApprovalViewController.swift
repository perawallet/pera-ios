//
//  LedgerApprovalViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 5.03.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerApprovalViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var ledgerApprovalView = LedgerApprovalView()
    
    override func configureAppearance() {
        view.backgroundColor = Colors.backgroundColor
    }
    
    override func setListeners() {
        ledgerApprovalView.delegate = self
    }
    
    override func prepareLayout() {
        setupLedgerApprovalViewLayout()
    }
}

extension LedgerApprovalViewController {
    private func setupLedgerApprovalViewLayout() {
        view.addSubview(ledgerApprovalView)
        
        ledgerApprovalView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
}

extension LedgerApprovalViewController: LedgerApprovalViewDelegate {
    func ledgerApprovalViewDidTapCancelButton(_ ledgerApprovalView: LedgerApprovalView) {
        dismissScreen()
    }
}

extension LedgerApprovalViewController {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
    }
}

extension LedgerApprovalViewController {
    private enum Colors {
        static let backgroundColor = rgba(0.29, 0.29, 0.31, 0.6)
    }
}
