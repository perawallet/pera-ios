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
    
    private let mode: Mode
    
    init(mode: Mode, configuration: ViewControllerConfiguration) {
        self.mode = mode
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.backgroundColor
        if mode == .connection {
            setConnectionModeTexts()
        } else {
            setApproveModeTexts()
        }
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
        if parent != nil {
            removeFromParentController()
        }
    }
}

extension LedgerApprovalViewController {
    private func setConnectionModeTexts() {
        ledgerApprovalView.setTitle("ledger-approval-connection-title".localized)
        ledgerApprovalView.setDetail("ledger-approval-connection-message".localized)
    }
    
    private func setApproveModeTexts() {
        ledgerApprovalView.setTitle("ledger-approval-title".localized)
        ledgerApprovalView.setDetail("ledger-approval-message".localized)
    }
}

extension LedgerApprovalViewController {
    enum Mode {
        case connection
        case approve
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
