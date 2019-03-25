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
        
        passPhraseBackUpView.passPhreaseLabel.attributedText = passPhrase.attributed([.lineSpacing(1.5)])
        
        title = "new-account-title".localized
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
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
    
    func passPhraseBackUpViewDidTapShareButton(_ passPhraseBackUpView: PassPhraseBackUpView) {
        let sharedItem = [passPhrase]
        let activityViewController = UIActivityViewController(activityItems: sharedItem, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
        
        navigationController?.present(activityViewController, animated: true, completion: nil)
    }
    
    func passPhraseBackUpViewDidTapVerifyButton(_ passPhraseBackUpView: PassPhraseBackUpView) {
        open(.passPhraseVerify, by: .push)
    }
}
