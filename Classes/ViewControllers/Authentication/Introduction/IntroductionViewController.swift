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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentTermsAndServicesIfNeeded()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        view.backgroundColor = SharedColors.secondaryBackground
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
    func introductionViewDidTapCreateAccountButton(_ introductionView: IntroductionView) {
        open(.choosePassword(mode: .setup, route: nil), by: .push)
    }
    
    func introductionViewDidTapPairLedgerAccountButton(_ introductionView: IntroductionView) {
        open(.ledgerTutorial(mode: .initialize), by: .push)
    }
    
    func introductionViewDidTapRecoverButton(_ introductionView: IntroductionView) {
        open(.accountRecover(mode: .initialize), by: .push)
    }
}
