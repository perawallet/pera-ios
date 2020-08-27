//
//  RekeyInstructionsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 31.07.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class RekeyInstructionsViewController: BaseScrollViewController {
    
    private lazy var rekeyInstructionsView = RekeyInstructionsView()
    
    private let account: Account
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        rekeyInstructionsView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupRekeyInstructionsViewLayout()
    }
}

extension RekeyInstructionsViewController {
    private func setupRekeyInstructionsViewLayout() {
        contentView.addSubview(rekeyInstructionsView)
        
        rekeyInstructionsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension RekeyInstructionsViewController: RekeyInstructionsViewDelegate {
    func rekeyInstructionsViewDidStartRekeying(_ rekeyInstructionsView: RekeyInstructionsView) {
        open(.ledgerDeviceList(flow: .addNewAccount(mode: .rekey(account: account))), by: .push)
    }
}
