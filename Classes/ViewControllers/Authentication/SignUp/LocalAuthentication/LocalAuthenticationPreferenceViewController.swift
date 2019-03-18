//
//  LocalAuthenticationAuthorizationViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class LocalAuthenticationPreferenceViewController: BaseViewController {
    
    // MARK: Components
    
    private lazy var localAuthenticationPreferenceView: LocalAuthenticationPreferenceView = {
        let view = LocalAuthenticationPreferenceView()
        return view
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        view.backgroundColor = rgb(0.95, 0.96, 0.96)
    }
    
    override func prepareLayout() {
        view.addSubview(localAuthenticationPreferenceView)
        
        localAuthenticationPreferenceView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.safeEqualToBottom(of: self)
        }
    }
    
    override func linkInteractors() {
        localAuthenticationPreferenceView.delegate = self
    }
}

extension LocalAuthenticationPreferenceViewController: LocalAuthenticationPreferenceViewDelegate {
    
    func localAuthenticationPreferenceViewDidTapYesButton(_ localAuthenticationPreferenceView: LocalAuthenticationPreferenceView) {
        
    }
    
    func localAuthenticationPreferenceViewDidTapNoButton(_ localAuthenticationPreferenceView: LocalAuthenticationPreferenceView) {
        
    }
}
