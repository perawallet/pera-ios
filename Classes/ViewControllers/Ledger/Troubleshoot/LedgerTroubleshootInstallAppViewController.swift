//
//  LedgerTroubleshootInstallAppViewController.swift
//  algorand
//
//  Created by Omer Emre Aslan on 26.03.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit
import SafariServices

class LedgerTroubleshootInstallAppViewController: BaseScrollViewController {
    
    private lazy var ledgerTroubleshootInstallAppView = LedgerTroubleshootInstallAppView()
    
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
        title = "title-step-2".localized
        view.backgroundColor = SharedColors.secondaryBackground
        contentView.backgroundColor = SharedColors.secondaryBackground
        scrollView.backgroundColor = SharedColors.secondaryBackground
        navigationController?.navigationBar.barTintColor = SharedColors.secondaryBackground
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        ledgerTroubleshootInstallAppView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupSeparatorView()
        setupLedgerTroubleshootBluetoothView()
    }
}

extension LedgerTroubleshootInstallAppViewController {
    private func setupSeparatorView() {
        view.addSubview(separatorView)
        
        separatorView.snp.makeConstraints { maker in
            maker.top.equalTo(scrollView.snp.top)
            maker.leading.trailing.equalToSuperview()
            maker.height.equalTo(1.0)
        }
    }
    
    private func setupLedgerTroubleshootBluetoothView() {
        contentView.addSubview(ledgerTroubleshootInstallAppView)
        
        ledgerTroubleshootInstallAppView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension LedgerTroubleshootInstallAppViewController: LedgerTroubleshootInstallAppViewDelegate {
    func ledgerTroubleshootInstallAppView(_ view: LedgerTroubleshootInstallAppView, didTapUrl url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
}
