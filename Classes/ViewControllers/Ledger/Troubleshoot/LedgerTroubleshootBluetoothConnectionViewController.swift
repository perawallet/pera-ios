//
//  LedgerTroubleshootBluetoothConnectionViewController.swift
//  algorand
//
//  Created by Omer Emre Aslan on 25.03.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class LedgerTroubleshootBluetoothConnectionViewController: BaseScrollViewController {
    // MARK: Components
    
    private lazy var ledgerTroubleshootBluetoothConnectionView = LedgerTroubleshootBluetoothConnectionView()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = rgb(0.91, 0.91, 0.92)
        return view
    }()
    
    // MARK: View Lifecycle
    
    override func configureAppearance() {
        super.configureAppearance()
        
        navigationItem.titleView = UIImageView(image: img("icon-bluetooth-purple"))
        view.backgroundColor = .white
        contentView.backgroundColor = .white
        scrollView.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupSeparatorView()
        setupLedgerTroubleshootBluetoothView()
    }
    
    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.closeScreen(by: .dismiss, animated: true)
        }
        
        leftBarButtonItems = [closeBarButtonItem]
    }
    
    private func setupSeparatorView() {
        view.addSubview(separatorView)
        separatorView.snp.makeConstraints { maker in
            maker.top.equalTo(scrollView.snp.top)
            maker.leading.trailing.equalToSuperview()
            maker.height.equalTo(1)
        }
    }
    
    private func setupLedgerTroubleshootBluetoothView() {
        contentView.addSubview(ledgerTroubleshootBluetoothConnectionView)
        
        ledgerTroubleshootBluetoothConnectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
