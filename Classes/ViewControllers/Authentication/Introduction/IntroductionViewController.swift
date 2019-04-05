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
        let view = IntroductionView()
        return view
    }()
    
    var mode: AccountSetupMode = .initialize
    
    // MARK: Setup
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupIntroducitionViewLayout()
    }
    
    private func setupIntroducitionViewLayout() {
        contentView.addSubview(introductionView)
        
        introductionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(view.safeAreaTop)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func linkInteractors() {
        introductionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isTranslucent = false
    }
}

// MARK: IntroductionViewDelegate

extension IntroductionViewController: IntroductionViewDelegate {
    
    func introductionViewDidTapCreateAccountButton(_ introductionView: IntroductionView) {
        switch mode {
        case .initialize:
            open(.welcome, by: .push)
        case .new:
            open(.accountNameSetup(mode: mode), by: .push)
        }
    }
    
    func introductionViewDidTapRecoverButton(_ introductionView: IntroductionView) {
        open(.accountRecover(mode: mode), by: .push)
    }
}
