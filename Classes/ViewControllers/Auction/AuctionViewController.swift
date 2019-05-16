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
        let activeAuctionSize = CGSize(width: UIScreen.main.bounds.width, height: 338.0)
        let pastAuctionSize = CGSize(width: UIScreen.main.bounds.width, height: 80.0)
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
    
    private(set) lazy var auctionsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .zero
        collectionView.backgroundColor = .white
        
        collectionView.register(ActiveAuctionCell.self, forCellWithReuseIdentifier: ActiveAuctionCell.reusableIdentifier)
        collectionView.register(AuctionCell.self, forCellWithReuseIdentifier: AuctionCell.reusableIdentifier)
        
        return collectionView
    }()
    
    private var auctions = [Auction]()
    
    private var activeAuction: ActiveAuction?
    
    private let viewModel = AuctionViewModel()
    
    // MARK: Setup
    
    override func linkInteractors() {
        super.linkInteractors()
        
        auctionIntroductionView.delegate = self
        auctionEmptyView.delegate = self
        auctionsCollectionView.dataSource = self
        auctionsCollectionView.delegate = self
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        navigationItem.title = "auction-title".localized
        
        fetchActiveAuction()
    }
    
    private func fetchActiveAuction() {
        let activeAuctionDraft = AuctionDraft(accessToken: "1dd6e671c4ba97c1772b53bdb31f7a7fd775684251a64f17aa00879721c7a94e")
        
        api?.fetchActiveAuction(with: activeAuctionDraft) { response in
            switch response {
            case let .success(auction):
                self.activeAuction = auction
                
                self.fetchPastAuctions(top: auction.id)
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func fetchPastAuctions(top: Int) {
        let pastAuctionsDraft = AuctionDraft(
            accessToken: "1dd6e671c4ba97c1772b53bdb31f7a7fd775684251a64f17aa00879721c7a94e",
            topCount: top
        )
        
        api?.fetchPastAuctions(with: pastAuctionsDraft) { response in
            switch response {
            case let .success(pastAuctions):
                self.auctions = pastAuctions
                
                self.configureAuctionsCollectionView()
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func configureAuctionsCollectionView() {
        if auctions.isEmpty {
            auctionIntroductionView.isHidden = true
            auctionEmptyView.isHidden = false
            auctionsCollectionView.reloadData()
            return
        }
        
        auctionIntroductionView.isHidden = true
        auctionEmptyView.isHidden = true
        
        auctionsCollectionView.reloadData()
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupAuctionIntroductionViewLayout()
        setupAuctionEmptyViewLayout()
        setupAuctionsCollectionViewLayout()
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
    
    private func setupAuctionsCollectionViewLayout() {
        view.addSubview(auctionsCollectionView)
        
        auctionsCollectionView.snp.makeConstraints { make in
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
        
    }
}

// MARK: UICollectionViewDataSource

extension AuctionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return auctions.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ActiveAuctionCell.reusableIdentifier,
                for: indexPath) as? ActiveAuctionCell else {
                    fatalError("Index path is out of bounds")
            }
            
            if let activeAuction = activeAuction {
                viewModel.configure(cell, with: activeAuction)
            }
            
            return cell
        }
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AuctionCell.reusableIdentifier,
            for: indexPath) as? AuctionCell else {
                fatalError("Index path is out of bounds")
        }
        
        if indexPath.item < auctions.count {
            let auction = auctions[indexPath.row + 1]
            
            if let activeAuction = activeAuction {
                viewModel.configure(cell, with: auction, and: activeAuction)
            }
        }
        
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension AuctionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        if indexPath.section == 0 {
            return layout.current.activeAuctionSize
        }
        
        return layout.current.pastAuctionSize
    }
}

// MARK: ActiveAuctionCellDelegate

extension AuctionViewController: ActiveAuctionCellDelegate {
    
    func activeAuctionCellDidTapEnterAuctionButton(_ activeAuctionCell: ActiveAuctionCell) {
        open(.auctionDetail, by: .push)
    }
}
