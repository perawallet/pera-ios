// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  LedgerTroubleshootInstallAppViewController.swift

import UIKit
import SafariServices

class LedgerTroubleshootInstallAppViewController: BaseScrollViewController {
    
    private lazy var ledgerTroubleshootInstallAppView = LedgerTroubleshootInstallAppView()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.Component.separator
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
        view.backgroundColor = Colors.Background.tertiary
        contentView.backgroundColor = Colors.Background.tertiary
        scrollView.backgroundColor = Colors.Background.tertiary
        setTertiaryBackgroundColor()
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
