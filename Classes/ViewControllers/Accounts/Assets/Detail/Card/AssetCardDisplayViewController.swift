//
//  AssetCardDisplayViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 15.10.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit

class AssetCardDisplayViewController: BaseViewController {
    
    weak var delegate: AssetCardDisplayViewControllerDelegate?
    
    private lazy var rewardsModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 472.0))
    )
    
    private var account: Account
    private var selectedIndex: Int
    private var currency: Currency?
    
    private lazy var assetCardDisplayView = AssetCardDisplayView()
    
    init(account: Account, selectedIndex: Int, configuration: ViewControllerConfiguration) {
        self.account = account
        self.selectedIndex = selectedIndex
        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrency()
        assetCardDisplayView.setNumberOfPages(account.assetDetails.count + 1)
        assetCardDisplayView.setCurrentPage(selectedIndex)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        assetCardDisplayView.scrollTo(selectedIndex, animated: true)
    }
    
    override func prepareLayout() {
        setupAssetCardDisplayViewLayout()
    }
    
    override func linkInteractors() {
        assetCardDisplayView.setDelegate(self)
        assetCardDisplayView.setDataSource(self)
    }
}

extension AssetCardDisplayViewController {
    private func setupAssetCardDisplayViewLayout() {
        view.addSubview(assetCardDisplayView)
        
        assetCardDisplayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AssetCardDisplayViewController {
    private func fetchCurrency() {
        guard let preferredCurrency = session?.preferredCurrency else {
            return
        }
        
        api?.getCurrencyValue(for: preferredCurrency) { response in
            switch response {
            case let .success(result):
                self.currency = result
                self.assetCardDisplayView.reloadData(at: 0)
            case .failure:
                break
            }
        }
    }
}

extension AssetCardDisplayViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return account.assetDetails.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AlgosCardCell.reusableIdentifier,
                for: indexPath
            ) as? AlgosCardCell {
                cell.delegate = self
                cell.contextView.bind(AlgosCardViewModel(account: account, currency: currency))
                return cell
            }
        } else {
            if let assetDetail = account.assetDetails[safe: indexPath.item - 1],
               let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AssetCardCell.reusableIdentifier,
                for: indexPath
            ) as? AssetCardCell {
                cell.delegate = self
                cell.contextView.bind(AssetCardViewModel(account: account, assetDetail: assetDetail))
                return cell
            }
        }
        
        fatalError("Index path is out of bounds")
    }
}

extension AssetCardDisplayViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(
            width: AssetCardDisplayView.CardViewConstants.cardWidth,
            height: AssetCardDisplayView.CardViewConstants.cardHeight
        )
    }
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let pageWidth = AssetCardDisplayView.CardViewConstants.cardWidth + AssetCardDisplayView.CardViewConstants.cardSpacing
        var currentPage = CGFloat(assetCardDisplayView.currentPage)
        
        if velocity.x == 0 {
            currentPage = floor((targetContentOffset.pointee.x - pageWidth / 2) / pageWidth) + 1.0
        } else {
            currentPage = CGFloat(velocity.x > 0 ? assetCardDisplayView.currentPage + 1 : assetCardDisplayView.currentPage - 1)
            if currentPage < 0 {
                return
            }
            
            if currentPage > assetCardDisplayView.contentWidth / pageWidth {
                currentPage = ceil(assetCardDisplayView.contentWidth / pageWidth) - 1.0
            }
        }
        
        if currentPage >= CGFloat(assetCardDisplayView.numberOfPages) {
            return
        }
        
        selectedIndex = Int(currentPage)
        assetCardDisplayView.setCurrentPage(selectedIndex)
        targetContentOffset.pointee = CGPoint(x: currentPage * pageWidth, y: targetContentOffset.pointee.y)
        delegate?.assetCardDisplayViewController(self, didSelect: selectedIndex)
    }
}

extension AssetCardDisplayViewController: AlgosCardCellDelegate {
    func algosCardCellDidOpenRewardDetails(_ algosCardCell: AlgosCardCell) {
        open(
            .rewardDetail(account: account),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: rewardsModalPresenter
            )
        )
    }
}

extension AssetCardDisplayViewController: AssetCardCellDelegate {
    func assetCardCellDidCopyAssetId(_ assetCardCell: AssetCardCell) {
        guard let index = assetCardDisplayView.index(for: assetCardCell),
              let assetDetail = account.assetDetails[safe: index] else {
            return
        }
        
        NotificationBanner.showInformation("asset-id-copied-title".localized)
        UIPasteboard.general.string = "\(assetDetail.id)"
    }
}

extension AssetCardDisplayViewController {
    func updateAccount(_ updatedAccount: Account) {
        account = updatedAccount
        assetCardDisplayView.reloadData()
    }
}

protocol AssetCardDisplayViewControllerDelegate: class {
    func assetCardDisplayViewController(_ assetCardDisplayViewController: AssetCardDisplayViewController, didSelect index: Int)
}
