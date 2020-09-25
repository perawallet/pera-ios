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
    
    private lazy var termsServiceModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 300))
    )
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentTermsAndServicesIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        introductionView.animateImages()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        view.backgroundColor = SharedColors.secondaryBackground
        setSecondaryBackgroundColor()
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
    private func presentTermsAndServicesIfNeeded() {
        guard let session = self.session, !session.isTermsAndServicesAccepted() else {
            return
        }
        
        let transitionStyle = Screen.Transition.Open.customPresent(
            presentationStyle: .custom,
            transitionStyle: nil,
            transitioningDelegate: termsServiceModalPresenter
        )
        
        open(.termsAndServices, by: transitionStyle)
    }
}

extension IntroductionViewController: IntroductionViewDelegate {
    func introductionViewDidAddAccount(_ introductionView: IntroductionView) {
        open(.accountTypeSelection(flow: accountSetupFlow), by: .push)
    }
    
    func introductionViewDidOpenTermsAndConditions(_ introductionView: IntroductionView) {
        if let termsAndServicesURL = URL(string: "https://www.algorand.com/wallet-disclaimer") {
            open(termsAndServicesURL)
        }
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
