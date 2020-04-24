//
//  LedgerTroubleshootBluetoothViewController.swift
//  algorand
//
//  Created by Omer Emre Aslan on 24.03.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit
import SafariServices

class LedgerTroubleshootBluetoothViewController: BaseScrollViewController {
    
    private lazy var ledgerTroubleshootBluetoothView = LedgerTroubleshootBluetoothView()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = color("gray100")
        return view
    }()
    
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
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "title-step-1".localized
        view.backgroundColor = .white
        contentView.backgroundColor = .white
        scrollView.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        ledgerTroubleshootBluetoothView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupSeparatorView()
        setupLedgerTroubleshootBluetoothView()
    }
}

extension LedgerTroubleshootBluetoothViewController {
    private func setupSeparatorView() {
        view.addSubview(separatorView)
        
        separatorView.snp.makeConstraints { maker in
            maker.top.equalTo(scrollView.snp.top)
            maker.leading.trailing.equalToSuperview()
            maker.height.equalTo(1.0)
        }
    }
    
    private func setupLedgerTroubleshootBluetoothView() {
        contentView.addSubview(ledgerTroubleshootBluetoothView)
        
        ledgerTroubleshootBluetoothView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension LedgerTroubleshootBluetoothViewController: LedgerTroubleshootBluetoothViewDelegate {
    func ledgerTroubleshootBluetoothView(_ view: LedgerTroubleshootBluetoothView, didTapUrl url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
}
