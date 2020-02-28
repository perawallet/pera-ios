//
//  IntroductionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class IntroductionViewController: BaseViewController {
    
    private lazy var introductionView = IntroductionView(mode: self.mode)
    
    var mode: AccountSetupMode = .initialize
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.barTintColor = SharedColors.warmWhite
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        view.backgroundColor = .white
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

extension IntroductionViewController: IntroductionViewDelegate {
    func introductionViewDidTapCreateAccountButton(_ introductionView: IntroductionView) {
        switch mode {
        case .initialize:
            open(.choosePassword(mode: .setup, route: nil), by: .push)
        case .new:
            open(.passphraseView(address: "temp"), by: .push)
        }
    }
    
    func introductionViewDidTapPairLedgerAccountButton(_ introductionView: IntroductionView) {
        open(.ledgerTutorial(mode: mode), by: .push)
    }
    
    func introductionViewDidTapRecoverButton(_ introductionView: IntroductionView) {
        open(.accountRecover(mode: mode), by: .push)
    }
    
    func introductionViewDidTapCloseButton(_ introductionView: IntroductionView) {
        dismissScreen()
    }
}
