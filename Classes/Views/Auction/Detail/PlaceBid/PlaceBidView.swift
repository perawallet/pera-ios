//
//  PlaceBidView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

protocol PlaceBidViewDelegate: class {
    
    func placeBidViewDidTapPlaceBidButton(_ placeBidView: PlaceBidView)
}

class PlaceBidView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 15.0
        let verticalInset: CGFloat = 10.0
        let bidAmountViewHeight: CGFloat = 151.0
        let maxPriceViewHeight: CGFloat = 50.0
        let potentialAlgosViewHeight: CGFloat = 62.0
        let buttonHeight: CGFloat = 56.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var bidAmountView: BidAmountView = {
        let view = BidAmountView()
        return view
    }()

    private(set) lazy var maxPriceView: MaximumPriceView = {
        let view = MaximumPriceView()
        return view
    }()
    
    private(set) lazy var minPotentialAlgosView: PotentialAlgosDisplayView = {
        let view = PotentialAlgosDisplayView(mode: .minimum)
        return view
    }()
    
    private(set) lazy var placeBidButton: AuctionBidButton = {
        let button = AuctionBidButton()
        button.setTitle("auction-detail-place-bid-button-title".localized, for: .normal)
        button.isEnabled = false
        return button
    }()
    
    weak var delegate: PlaceBidViewDelegate?
    
    // MARK: Setup
    
    override func setListeners() {
        placeBidButton.addTarget(self, action: #selector(notifyDelegateToPlaceBidButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupBidAmountViewLayout()
        setupMaxPriceViewLayout()
        setupMinPotentialAlgosViewLayout()
        setupPlaceBidButtonLayout()
    }
    
    private func setupBidAmountViewLayout() {
        addSubview(bidAmountView)
        
        bidAmountView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview().inset(layout.current.defaultInset)
            make.height.equalTo(layout.current.bidAmountViewHeight)
        }
    }
    
    private func setupMaxPriceViewLayout() {
        addSubview(maxPriceView)
        
        maxPriceView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.height.equalTo(layout.current.maxPriceViewHeight)
            make.top.equalTo(bidAmountView.snp.bottom).offset(layout.current.verticalInset)
        }
    }
    
    private func setupMinPotentialAlgosViewLayout() {
        addSubview(minPotentialAlgosView)
        
        minPotentialAlgosView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.height.equalTo(layout.current.potentialAlgosViewHeight)
            make.top.equalTo(maxPriceView.snp.bottom).offset(layout.current.verticalInset)
        }
    }
    
    private func setupPlaceBidButtonLayout() {
        addSubview(placeBidButton)
        
        placeBidButton.snp.makeConstraints { make in
            make.top.equalTo(minPotentialAlgosView.snp.bottom).offset(layout.current.defaultInset)
            make.height.equalTo(layout.current.buttonHeight)
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.bottom.lessThanOrEqualToSuperview().inset(layout.current.defaultInset + safeAreaBottom)
        }
    }
    
    // MARK: Actions
    
    @objc
    private func notifyDelegateToPlaceBidButtonTapped() {
        delegate?.placeBidViewDidTapPlaceBidButton(self)
    }
}
