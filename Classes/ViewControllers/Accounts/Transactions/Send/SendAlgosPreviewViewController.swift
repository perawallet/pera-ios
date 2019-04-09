//
//  SendAlgosPreviewViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 9.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class SendAlgosPreviewViewController: BaseViewController {
    
    // MARK: Components
    
    private lazy var sendAlgosPreviewView: SendAlgosPreviewView = {
        let view = SendAlgosPreviewView()
        return view
    }()
    
    // MARK: Initialization
    
    override init(configuration: ViewControllerConfiguration) {
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "send-algos-title".localized
    }
    
    override func linkInteractors() {
        sendAlgosPreviewView.previewViewDelegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupSendAlgosPreviewViewLayout()
    }
    
    private func setupSendAlgosPreviewViewLayout() {
        view.addSubview(sendAlgosPreviewView)
        
        sendAlgosPreviewView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.safeEqualToBottom(of: self)
        }
    }
}

// MARK: SendAlgosPreviewViewDelegate

extension SendAlgosPreviewViewController: SendAlgosPreviewViewDelegate {
    
    func sendAlgosPreviewViewDidTapSendButton(_ sendAlgosView: SendAlgosView) {
        // TODO: Complete transctions
        
        open(.sendAlgosSuccess, by: .present)
    }
}
