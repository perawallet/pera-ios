//
//  LedgerTroubleshootBluetoothConnectionViewController.swift
//  algorand
//
//  Created by Omer Emre Aslan on 25.03.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerTroubleshootBluetoothConnectionViewController: BaseScrollViewController {
    
    private lazy var ledgerTroubleshootBluetoothConnectionView = LedgerTroubleshootBluetoothConnectionView()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = SharedColors.gray100
        return view
    }()
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "title-step-4".localized
        view.backgroundColor = SharedColors.secondaryBackground
        contentView.backgroundColor = SharedColors.secondaryBackground
        scrollView.backgroundColor = SharedColors.secondaryBackground
        navigationController?.navigationBar.barTintColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupSeparatorView()
        setupLedgerTroubleshootBluetoothView()
    }
}

extension LedgerTroubleshootBluetoothConnectionViewController {
    private func setupSeparatorView() {
        view.addSubview(separatorView)
        
        separatorView.snp.makeConstraints { maker in
            maker.top.equalTo(scrollView.snp.top)
            maker.leading.trailing.equalToSuperview()
            maker.height.equalTo(1.0)
        }
    }
    
    private func setupLedgerTroubleshootBluetoothView() {
        contentView.addSubview(ledgerTroubleshootBluetoothConnectionView)
        
        ledgerTroubleshootBluetoothConnectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
