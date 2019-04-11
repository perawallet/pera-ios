//
//  ReceiveAlgosPreviewViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ReceiveAlgosPreviewViewController: BaseScrollViewController {

    // MARK: Components
    
    private lazy var receiveAlgosPreviewView: ReceiveAlgosPreviewView = {
        let view = ReceiveAlgosPreviewView()
        return view
    }()
    
    private let transaction: Transaction
    
    // MARK: Initialization
    
    init(transaction: Transaction, configuration: ViewControllerConfiguration) {
        self.transaction = transaction
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "receive-algos-title".localized
        
        receiveAlgosPreviewView.algosInputView.inputTextField.text = "\(transaction.amount)"
        receiveAlgosPreviewView.accountSelectionView.inputTextField.text = ""
    }
    
    override func linkInteractors() {
        receiveAlgosPreviewView.previewViewDelegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupReceiveAlgosPreviewViewLayout()
    }
    
    private func setupReceiveAlgosPreviewViewLayout() {
        contentView.addSubview(receiveAlgosPreviewView)
        
        receiveAlgosPreviewView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(view.safeAreaBottom)
        }
    }
}

// MARK: ReceiveAlgosPreviewViewDelegate

extension ReceiveAlgosPreviewViewController: ReceiveAlgosPreviewViewDelegate {
    
    func receiveAlgosPreviewViewDidTapShareButton(_ receiveAlgosPreviewView: ReceiveAlgosPreviewView) {
        // TODO: Share action
    }
}
