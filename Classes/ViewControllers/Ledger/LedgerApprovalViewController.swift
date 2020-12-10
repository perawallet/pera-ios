//
//  LedgerApprovalViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 5.03.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerApprovalViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private lazy var ledgerApprovalView = LedgerApprovalView()
    
    private let mode: Mode
    
    init(mode: Mode, configuration: ViewControllerConfiguration) {
        self.mode = mode
        super.init(configuration: configuration)
    }
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.secondary
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ledgerApprovalView.bluetoothImageView.show()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ledgerApprovalView.bluetoothImageView.stop()
    }
}

extension LedgerApprovalViewController {
    private func setupLedgerApprovalViewLayout() {
        view.addSubview(ledgerApprovalView)
        
        ledgerApprovalView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension LedgerApprovalViewController: LedgerApprovalViewDelegate {
    func ledgerApprovalViewDidTapCancelButton(_ ledgerApprovalView: LedgerApprovalView) {
        dismissScreen()
    }
    
    func dismissIfNeeded() {
        if isModal {
            dismissScreen()
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
