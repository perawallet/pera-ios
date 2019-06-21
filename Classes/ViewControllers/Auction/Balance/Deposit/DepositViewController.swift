//
//  DepositViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 14.06.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class DepositViewController: BaseScrollViewController {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 20.0 * verticalScale
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private var user: AuctionUser
    
    // MARK: Components
    
    private lazy var depositView: DepositView = {
        let view = DepositView()
        return view
    }()
    
    // MARK: Initialization
    
    init(user: AuctionUser, configuration: ViewControllerConfiguration) {
        self.user = user
        
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        navigationItem.title = "deposit-title".localized
    }
    
    override func linkInteractors() {
        depositView.delegate = self
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupDepositViewLayout()
    }
    
    private func setupDepositViewLayout() {
        contentView.addSubview(depositView)
        
        depositView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: DepositViewDelegate

extension DepositViewController: DepositViewDelegate {
    
    func depositViewDidTapDepositButton(_ depositView: DepositView) {
        
    }
    
    func depositViewDidTapCancelButton(_ depositView: DepositView) {
        popScreen()
    }
    
    func depositView(_ depositView: DepositView, didSelect depositType: DepositType) {
        
    }
}
