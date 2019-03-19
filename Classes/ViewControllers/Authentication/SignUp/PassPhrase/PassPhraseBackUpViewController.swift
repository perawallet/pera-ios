//
//  PassPhraseBackUpViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassPhraseBackUpViewController: BaseViewController {

    // MARK: Components
    
    private lazy var passPhraseBackUpView: PassPhraseBackUpView = {
        let view = PassPhraseBackUpView()
        return view
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        view.backgroundColor = rgb(0.95, 0.96, 0.96)
    }
    
    override func prepareLayout() {
        view.addSubview(passPhraseBackUpView)
        
        passPhraseBackUpView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.safeEqualToBottom(of: self)
        }
    }
    
    override func linkInteractors() {
        passPhraseBackUpView.delegate = self
    }
}

extension PassPhraseBackUpViewController: PassPhraseBackUpViewDelegate {
    
    func passPhraseBackUpViewDidTapVerifyButton(_ passPhraseBackUpView: PassPhraseBackUpView) {
        
    }
}
