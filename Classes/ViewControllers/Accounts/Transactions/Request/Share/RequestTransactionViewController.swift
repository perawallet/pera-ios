//
//  RequestTransactionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class RequestTransactionViewController: BaseScrollViewController {
    
    private let isPresented: Bool
    
    init(isPresented: Bool, configuration: ViewControllerConfiguration) {
        self.isPresented = isPresented
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        let closeBarButtonItem = ALGBarButtonItem(kind: .close) { [weak self] in
            self?.closeScreen(by: .dismiss, animated: true)
        }
        
        if isPresented {
            leftBarButtonItems = [closeBarButtonItem]
        }
    }
}

extension RequestTransactionViewController {
    func prepareLayout(of requestTransactionView: RequestTransactionView) {
        contentView.addSubview(requestTransactionView)
        
        requestTransactionView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(view.safeAreaBottom)
        }
    }
}

extension RequestTransactionViewController: RequestTransactionViewDelegate {
    func requestTransactionViewDidTapShareButton(_ requestTransactionView: RequestTransactionView) {
        guard let shareUrl = URL(string: requestTransactionView.qrView.qrText.qrText()) else {
            return
        }
        
        let sharedItem = [shareUrl]
        let activityViewController = UIActivityViewController(activityItems: sharedItem, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList]
        navigationController?.present(activityViewController, animated: true, completion: nil)
    }
}
