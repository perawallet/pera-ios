//
//  IntroductionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class IntroductionViewController: BaseViewController {
    
    private lazy var introductionView = IntroductionView()
    
    private let accountSetupFlow: AccountSetupFlow
    
    init(accountSetupFlow: AccountSetupFlow, configuration: ViewControllerConfiguration) {
        self.accountSetupFlow = accountSetupFlow
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [unowned self] in
            self.closeScreen(by: .dismiss, animated: true)
        }
        
        switch accountSetupFlow {
        case .addNewAccount:
            leftBarButtonItems = [closeBarButtonItem]
        default:
            break
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        introductionView.animateImages()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        view.backgroundColor = SharedColors.secondaryBackground
        setSecondaryBackgroundColor()
        
        switch accountSetupFlow {
        case .addNewAccount:
            introductionView.setTitle("introduction-title-add-text".localized)
        case .initializeAccount:
            introductionView.setTitle("introduction-title-text".localized)
        }
    }
    
    override func setListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didApplicationEnterForeground),
            name: .ApplicationWillEnterForeground,
            object: nil
        )
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupIntroducitionViewLayout()
    }
    
    override func linkInteractors() {
        introductionView.delegate = self
    }
}

extension IntroductionViewController {
    private func setupIntroducitionViewLayout() {
        view.addSubview(introductionView)
        
        introductionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension IntroductionViewController {
    @objc
    private func didApplicationEnterForeground() {
        introductionView.animateImages()
    }
}

extension IntroductionViewController: IntroductionViewDelegate {
    func introductionViewDidAddAccount(_ introductionView: IntroductionView) {
        open(.accountTypeSelection(flow: accountSetupFlow), by: .push)
    }
    
    func introductionView(_ introductionView: IntroductionView, didOpen url: URL) {
        open(url)
    }
}

enum AccountSetupFlow {
    case initializeAccount(mode: AccountSetupMode?)
    case addNewAccount(mode: AccountSetupMode?)
}

enum AccountSetupMode {
    case create
    case pair
    case recover
    case rekey(account: Account)
    case watch
}
