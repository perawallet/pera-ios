//
//  PassPhraseBackUpViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PassPhraseBackUpViewController: BaseScrollViewController {
    
    private let passPhrase = """
                            quarters unific unlive planned faculty pang neuron grogshop scale overflow moreover clout rainy
                            rajah bebop coition marplot turncoat outpour fimble calyces serjeant cuprum sailboat
                            """

    // MARK: Components
    
    private lazy var passPhraseBackUpView: PassPhraseBackUpView = {
        let view = PassPhraseBackUpView()
        return view
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        view.backgroundColor = rgb(0.95, 0.96, 0.96)
        
        passPhraseBackUpView.passPhreaseLabel.attributedText = passPhrase.attributed([.lineSpacing(1.5)])
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        shouldIgnoreBottomLayoutGuide = false
        
        contentView.addSubview(passPhraseBackUpView)
        
        passPhraseBackUpView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func linkInteractors() {
        passPhraseBackUpView.delegate = self
    }
}

extension PassPhraseBackUpViewController: PassPhraseBackUpViewDelegate {
    
    func passPhraseBackUpViewDidTapVerifyButton(_ passPhraseBackUpView: PassPhraseBackUpView) {
        open(.accountNameSetup, by: .push)
    }
}
