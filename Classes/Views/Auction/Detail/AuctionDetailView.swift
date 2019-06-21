//
//  AuctionDetailView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 20.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol AuctionDetailViewDelegate: class {
    
    func auctionDetailViewDidTapPlaceBidButton(_ auctionDetailView: AuctionDetailView)
    func auctionDetailViewDidTapMyBidsButton(_ auctionDetailView: AuctionDetailView)
}

class AuctionDetailView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 20.0
        let defaultInset: CGFloat = 15.0
        let headerHeight: CGFloat = 185.0
        let minimumButtonInset: CGFloat = 5.0
        let buttonHeight: CGFloat = 44.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components

    private(set) lazy var auctionDetailHeaderView: AuctionDetailHeaderView = {
        let view = AuctionDetailHeaderView(initialValue: initialValue, maximumIndex: maximumIndex)
        return view
    }()
    
    private(set) lazy var placeBidButton: AuctionDetailHeaderButton = {
        let button = AuctionDetailHeaderButton()
        button.isSelected = true
        button.setTitle("auction-detail-place-bid-title".localized, for: .normal)
        return button
    }()
    
    private(set) lazy var myBidsButton: AuctionDetailHeaderButton = {
        let button = AuctionDetailHeaderButton(hasCornerLabel: true)
        button.setTitle("auction-detail-my-bids-title".localized, for: .normal)
        return button
    }()
    
    weak var delegate: AuctionDetailViewDelegate?
    
    private let initialValue: Double
    private let maximumIndex: Double
    
    // MARK: Initialization
    
    init(initialValue: Double, maximumIndex: Double) {
        self.initialValue = initialValue
        self.maximumIndex = maximumIndex
        
        super.init(frame: .zero)
    }
    
    // MARK: Setup
    
    override func setListeners() {
        placeBidButton.addTarget(self, action: #selector(notifyDelegateToPlaceBidButtonTapped), for: .touchUpInside)
        myBidsButton.addTarget(self, action: #selector(notifyDelegateToMysBidsButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupAuctionDetailHeaderViewLayout()
        setupPlaceBidButtonLayout()
        setupMyBidsButtonLayout()
    }
    
    private func setupAuctionDetailHeaderViewLayout() {
        addSubview(auctionDetailHeaderView)
        
        auctionDetailHeaderView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.height.equalTo(layout.current.headerHeight)
        }
    }
    
    private func setupPlaceBidButtonLayout() {
        addSubview(placeBidButton)
        
        placeBidButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalTo(auctionDetailHeaderView.snp.bottom).offset(layout.current.defaultInset)
            make.height.equalTo(layout.current.buttonHeight)
        }
    }
    
    private func setupMyBidsButtonLayout() {
        addSubview(myBidsButton)
        
        myBidsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalTo(placeBidButton)
            make.leading.equalTo(placeBidButton.snp.trailing).offset(layout.current.minimumButtonInset)
            make.width.height.equalTo(placeBidButton)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToPlaceBidButtonTapped() {
        myBidsButton.isSelected = false
        placeBidButton.isSelected = true
        
        delegate?.auctionDetailViewDidTapPlaceBidButton(self)
    }
    
    @objc
    private func notifyDelegateToMysBidsButtonTapped() {
        placeBidButton.isSelected = false
        myBidsButton.isSelected = true
        
        delegate?.auctionDetailViewDidTapMyBidsButton(self)
    }
}
