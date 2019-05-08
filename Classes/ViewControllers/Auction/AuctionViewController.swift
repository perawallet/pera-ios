//
//  AuctionsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AuctionViewController: BaseViewController {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 20.0 * verticalScale
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var auctionIntroductionView: AuctionIntroductionView = {
        let view = AuctionIntroductionView()
        return view
    }()
    
    private lazy var auctionEmptyView: AuctionEmptyView = {
        let view = AuctionEmptyView()
        view.isHidden = true
        return view
    }()
    
    // MARK: Setup
    
    override func linkInteractors() {
        super.linkInteractors()
        
        auctionIntroductionView.delegate = self
        auctionEmptyView.delegate = self
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        navigationItem.title = "auction-title".localized
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupAuctionIntroductionViewLayout()
        setupAuctionEmptyViewLayout()
    }
    
    private func setupAuctionIntroductionViewLayout() {
        view.addSubview(auctionIntroductionView)
        
        auctionIntroductionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupAuctionEmptyViewLayout() {
        view.addSubview(auctionEmptyView)
        
        auctionEmptyView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: AuctionEmptyViewDelegate

extension AuctionViewController: AuctionIntroductionViewDelegate {
    
    func auctionIntroductionViewDidTapGetStartedButton(_ auctionIntroductionView: AuctionIntroductionView) {
        auctionIntroductionView.isHidden = true
        auctionEmptyView.isHidden = false
    }
}

// MARK: AuctionEmptyViewDelegate

extension AuctionViewController: AuctionEmptyViewDelegate {
    
    func auctionEmptyViewDidTapGetStartedButton(_ auctionEmptyView: AuctionEmptyView) {
        open(.auctionDetail, by: .push)
    }
}
