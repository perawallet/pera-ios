//
//  IntroductionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class IntroductionViewController: BaseViewController {
    
    // MARK: Components

    private lazy var introductionView: IntroductionView = {
        let view = IntroductionView()
        return view
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        view.backgroundColor = rgb(0.95, 0.96, 0.96)
    }
    
    override func prepareLayout() {
        view.addSubview(introductionView)
        
        introductionView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.safeEqualToBottom(of: self)
        }
    }
    
    override func linkInteractors() {
        introductionView.delegate = self
    }
}

// MARK: IntroductionViewDelegate

extension IntroductionViewController: IntroductionViewDelegate {
    
    func introductionViewDidTapCreateAccountButton(_ introductionView: IntroductionView) {
        open(.welcome, by: .push)
    }
    
    func introductionViewDidTapRecoverButton(_ introductionView: IntroductionView) {
        
    }
}
