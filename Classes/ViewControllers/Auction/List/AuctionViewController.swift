//
//  AuctionsViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 1.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SVProgressHUD
import SafariServices

class AuctionViewController: BaseViewController {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 20.0 * verticalScale
        let activeAuctionSize = CGSize(width: UIScreen.main.bounds.width, height: 338.0)
        let pastAuctionSize = CGSize(width: UIScreen.main.bounds.width, height: 80.0)
        let pastAuctionEmptySize = CGSize(width: UIScreen.main.bounds.width, height: 295.0)
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var auctionIntroductionView: AuctionIntroductionView = {
        let view = AuctionIntroductionView()
        return view
    }()
    
    private lazy var auctionTemporaryView: AuctionTemporaryView = {
        let view = AuctionTemporaryView()
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
        collectionView.register(ActiveAuctionEmptyCell.self, forCellWithReuseIdentifier: ActiveAuctionEmptyCell.reusableIdentifier)
        collectionView.register(PastAuctionsEmptyCell.self, forCellWithReuseIdentifier: PastAuctionsEmptyCell.reusableIdentifier)
        
        return collectionView
    }()
    
    private var auctions = [Auction]()
    private var totalAlgosAmount: Int64?
    private var activeAuction: ActiveAuction?
    private var auctionUser: AuctionUser?
    
    private var isFirstCoinlistSetup = false
    
    private let viewModel = AuctionViewModel()
    
    private var pollingOperation: PollingOperation?
    
    private var authManager: AuthManager?
    
    private var canDisplayActiveAuctionEmptyState = false
    private var canDisplayPastAuctionsEmptyState = false
    
    override init(configuration: ViewControllerConfiguration) {
        super.init(configuration: configuration)
        
        authManager = AuthManager()
    }
    
    // MARK: Setup
    
    override func linkInteractors() {
        super.linkInteractors()
        
        auctionIntroductionView.delegate = self
        auctionsCollectionView.dataSource = self
        auctionsCollectionView.delegate = self
        authManager?.delegate = self
        auctionTemporaryView.delegate = self
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        
        navigationItem.title = "auction-title".localized
        
        if session?.coinlistToken == nil {
            return
        }
        
        SVProgressHUD.show(withStatus: "title-loading".localized)
        fetchAuctionUser()
        fetchActiveAuction()
    }
    
    private func fetchAuctionUser() {
        if session?.coinlistUserId == nil {
            return
        }
        
        api?.fetchAuctionUser { response in
            switch response {
            case let .success(user):
                self.auctionUser = user
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func fetchActiveAuction(withReload reload: Bool = true) {
        api?.fetchActiveAuction { response in
            switch response {
            case let .success(auction):
                self.activeAuction = auction
                
                if let status = auction.status {
                    self.auctionTemporaryView.status = status
                }
            case .failure:
                self.auctionTemporaryView.status = .announced
            }
            
            if reload {
                SVProgressHUD.showSuccess(withStatus: "title-done-lowercased".localized)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    private func fetchPastAuctions(top: Int) {
        api?.fetchPastAuctions(for: top) { response in
            switch response {
            case let .success(pastAuctions):
                self.auctions = pastAuctions
                
                self.auctionIntroductionView.isHidden = true
                
                self.canDisplayPastAuctionsEmptyState = pastAuctions.isEmpty
                
                if let recentAuction = pastAuctions.first {
                    self.totalAlgosAmount = recentAuction.algos
                }
                
                self.auctionsCollectionView.reloadSection(1)
            case .failure:
                self.canDisplayPastAuctionsEmptyState = true
                self.auctionsCollectionView.reloadSection(1)
            }
            
            SVProgressHUD.showSuccess(withStatus: "title-done-lowercased".localized)
            SVProgressHUD.dismiss()
        }
    }
    
    // View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if session?.coinlistToken == nil {
            return
        }
        
        if !isFirstCoinlistSetup {
            startPolling()
        }
    }
    
    private func startPolling() {
        pollingOperation = PollingOperation(interval: 5.0) { [weak self] in
            self?.fetchActiveAuction(withReload: false)
        }
        
        isFirstCoinlistSetup = false
        
        pollingOperation?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        pollingOperation?.invalidate()
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        prepareLayoutForToken()
    }
    
    private func prepareLayoutForToken() {
        if session?.coinlistToken == nil {
            setupAuctionIntroductionViewLayout()
        } else {
            auctionIntroductionView.removeFromSuperview()
            
            setupAuctionsCollectionViewLayout()
        }
    }
    
    private func setupAuctionIntroductionViewLayout() {
        view.addSubview(auctionIntroductionView)
        
        auctionIntroductionView.snp.makeConstraints { make in
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

// MARK: AuctionIntroductionViewDelegate

extension AuctionViewController: AuctionIntroductionViewDelegate {
    
    func auctionIntroductionViewDidTapGetStartedButton(_ auctionIntroductionView: AuctionIntroductionView) {
        authManager?.authorize()
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
        
        if auctions.isEmpty {
            return 1
        }
        
        return auctions.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if let activeAuction = activeAuction {
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ActiveAuctionCell.reusableIdentifier,
                    for: indexPath) as? ActiveAuctionCell else {
                        fatalError("Index path is out of bounds")
                }
                
                cell.delegate = self
                
                viewModel.configure(cell, with: activeAuction)
                
                return cell
            } else {
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ActiveAuctionEmptyCell.reusableIdentifier,
                    for: indexPath) as? ActiveAuctionEmptyCell else {
                        fatalError("Index path is out of bounds")
                }
                
                cell.contextView.isHidden = !canDisplayActiveAuctionEmptyState
                
                return cell
            }
        }
        
        if auctions.isEmpty {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PastAuctionsEmptyCell.reusableIdentifier,
                for: indexPath) as? PastAuctionsEmptyCell else {
                    fatalError("Index path is out of bounds")
            }
            
            cell.contextView.isHidden = !canDisplayPastAuctionsEmptyState
            
            return cell
        }
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AuctionCell.reusableIdentifier,
            for: indexPath) as? AuctionCell else {
                fatalError("Index path is out of bounds")
        }
        
        if indexPath.item < auctions.count {
            let auction = auctions[indexPath.row + 1]
            
            viewModel.configure(cell, with: auction, and: activeAuction)
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
        
        if auctions.isEmpty {
            return layout.current.pastAuctionEmptySize
        }
        
        return layout.current.pastAuctionSize
    }
}

// MARK: ActiveAuctionCellDelegate

extension AuctionViewController: ActiveAuctionCellDelegate {
    
    func activeAuctionCellDidTapEnterAuctionButton(_ activeAuctionCell: ActiveAuctionCell) {
        guard let auction = auctions.first,
            let user = auctionUser,
            let activeAuction = activeAuction else {
                return
        }
        
        open(.auctionDetail(auction: auction, user: user, activeAuction: activeAuction), by: .push)
    }
}

// MARK: AuthManagerDelegate

extension AuctionViewController: AuthManagerDelegate {
    
    func authManager(_ authManager: AuthManager, didCaptureToken token: String?, withError error: Error?) {
        if error != nil {
            displaySimpleAlertWith(title: "title-error".localized, message: "auction-auth-error-message".localized)
            self.authManager = AuthManager()
            self.authManager?.delegate = self
            
            return
        }
        
        guard let code = token else {
            return
        }
        
        isFirstCoinlistSetup = true
        
        SVProgressHUD.show(withStatus: "title-loading".localized)
        
        let draft = CoinlistAuthenticationDraft(
            code: code,
            grantType: "authorization_code",
            redirectURI: authManager.callbackUrlScheme
        )
        
        api?.authenticateCoinlist(with: draft) { response in
            switch response {
            case let .success(coinlistAuthentication):
                self.session?.coinlistToken = coinlistAuthentication.accessToken
                self.prepareLayoutForToken()
                
                self.api?.fetchCoinlistUser { response in
                    switch response {
                    case let .success(coinlistUser):
                        self.session?.coinlistUserId = coinlistUser.id
                        
                        self.fetchAuctionUser()
                        self.fetchActiveAuction()
                        self.startPolling()
                    case let .failure(error):
                        print(error)
                    }
                }
            case let .failure(error):
                print(error)
            }
        }

    }
}

// MARK: AuctionTemporaryViewDelegate

extension AuctionViewController: AuctionTemporaryViewDelegate {
    
    func auctionTemporaryViewDidTapGoToAuctionButton(_ auctionTemporaryView: AuctionTemporaryView) {
        guard let auctionUrl = URL(string: "https://auctions.algorand.foundation") else {
            return
        }
        
        let safariViewController = SFSafariViewController(url: auctionUrl)
        present(safariViewController, animated: true, completion: nil)
    }
}
