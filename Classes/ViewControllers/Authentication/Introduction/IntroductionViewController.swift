//
//  IntroductionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class IntroductionViewController: BaseScrollViewController {
    
    // MARK: Components

    private lazy var introductionView: IntroductionView = {
        let view = IntroductionView(mode: self.mode)
        return view
    }()
    
    var mode: AccountSetupMode = .initialize
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        if mode == .new {
            introductionView.welcomeLabel.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupIntroducitionViewLayout()
    }
    
    private func setupIntroducitionViewLayout() {
        contentView.addSubview(introductionView)
        
        introductionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func linkInteractors() {
        introductionView.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.barTintColor = SharedColors.warmWhite
    }
}

// MARK: IntroductionViewDelegate

extension IntroductionViewController: IntroductionViewDelegate {
    func introductionViewDidTapCloseButton(_ introductionView: IntroductionView) {
        dismissScreen()
    }
    
    func introductionViewDidTapCreateAccountButton(_ introductionView: IntroductionView) {
        switch mode {
        case .initialize:
            open(.choosePassword(mode: .setup, route: nil), by: .push)
        case .new:
            open(.passPhraseBackUp, by: .push)
        }
    }
    
    func introductionViewDidTapRecoverButton(_ introductionView: IntroductionView) {
        open(.accountRecover(mode: mode), by: .push)
    }
}
