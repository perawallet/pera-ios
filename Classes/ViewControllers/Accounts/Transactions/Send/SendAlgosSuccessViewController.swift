//
//  SendAlgosSuccessViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class SendAlgosSuccessViewController: BaseScrollViewController {

    // MARK: Components
    
    private lazy var sendAlgosSuccessView: SendAlgosSuccessView = {
        let view = SendAlgosSuccessView()
        return view
    }()
    
    // MARK: Initialization
    
    override init(configuration: ViewControllerConfiguration) {
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func linkInteractors() {
        sendAlgosSuccessView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupSendAlgosSuccessViewLayout()
    }
    
    private func setupSendAlgosSuccessViewLayout() {
        contentView.addSubview(sendAlgosSuccessView)
        
        sendAlgosSuccessView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: SendAlgosPreviewViewDelegate

extension SendAlgosSuccessViewController: SendAlgosSuccessViewDelegate {
    
    func sendAlgosSuccessViewDidTapDoneButton(_ sendAlgosSuccessView: SendAlgosSuccessView) {
        // TODO: Dismiss and go back to accounts tab with updated transaction history
        
        dismissScreen()
    }
    
    func sendAlgosSuccessViewDidTapSendMoreButton(_ sendAlgosSuccessView: SendAlgosSuccessView) {
        // TODO: Dismiss and go back to initial send algos view
    }
}
