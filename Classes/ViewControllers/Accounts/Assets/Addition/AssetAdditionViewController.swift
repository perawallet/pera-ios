//
//  AssetAdditionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import Magpie

protocol AssetAdditionViewControllerDelegate: class {
    func assetAdditionViewController(
        _ assetAdditionViewController: AssetAdditionViewController,
        didAdd assetSearchResult: AssetSearchResult,
        to account: Account
    )
}

class AssetAdditionViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AssetAdditionViewControllerDelegate?
    
    private var account: Account
    
    private var assetResults = [AssetSearchResult]()
    private let searchLimit = 50
    private var searchOffset = 0
    private var hasNext = false
    private let paginationRequestOffset = 3
    private var assetSearchFilters = AssetSearchFilter.verified
    
    private lazy var assetAdditionView = AssetAdditionView()
    
    private lazy var emptyStateView = EmptyStateView(title: "asset-not-found".localized, topImage: nil, bottomImage: nil)
    
    private let viewModel = AssetAdditionViewModel()
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
        hidesBottomBarWhenPushed = true
    }
    
    override func configureNavigationBarAppearance() {
        let infoBarButton = ALGBarButtonItem(kind: .infoFilled) { [weak self] in
        }

        rightBarButtonItems = [infoBarButton]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAssets(with: nil, isPaginated: false)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        navigationItem.title = "title-add-asset".localized
    }
    
    override func setListeners() {
        assetAdditionView.delegate = self
        assetAdditionView.assetInputView.delegate = self
        assetAdditionView.assetsCollectionView.delegate = self
        assetAdditionView.assetsCollectionView.dataSource = self
        transactionController?.delegate = self
    }
    
    override func prepareLayout() {
        setupAssetAdditionViewLayout()
    }
}

extension AssetAdditionViewController {
    private func setupAssetAdditionViewLayout() {
        view.addSubview(assetAdditionView)
        
        assetAdditionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AssetAdditionViewController {
    private func fetchAssets(with query: String?, isPaginated: Bool) {
        let searchDraft = AssetSearchQuery(status: assetSearchFilters, query: query, limit: searchLimit, offset: searchOffset)
        api?.searchAssets(with: searchDraft) { [weak self] response in
            switch response {
            case let .success(searchResults):
                guard let strongSelf = self else {
                    return
                }
                
                if isPaginated {
                    strongSelf.assetResults.append(contentsOf: searchResults.results)
                } else {
                    strongSelf.assetResults = searchResults.results
                }
                
                strongSelf.searchOffset += searchResults.results.count
                strongSelf.hasNext = searchResults.next != nil
                
                if strongSelf.assetResults.isEmpty {
                    strongSelf.assetAdditionView.assetsCollectionView.contentState = .empty(strongSelf.emptyStateView)
                } else {
                    strongSelf.assetAdditionView.assetsCollectionView.contentState = .none
                }
                
                strongSelf.assetAdditionView.assetsCollectionView.reloadData()
            case .failure:
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.assetAdditionView.assetsCollectionView.contentState = .empty(strongSelf.emptyStateView)
                strongSelf.assetAdditionView.assetsCollectionView.reloadData()
            }
        }
    }
}

extension AssetAdditionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AssetSelectionCell.reusableIdentifier,
            for: indexPath) as? AssetSelectionCell else {
                fatalError("Index path is out of bounds")
        }
        
        let assetResult = assetResults[indexPath.item]
        viewModel.configure(cell, with: assetResult)
        
        return cell
    }
}

extension AssetAdditionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let assetResult = assetResults[indexPath.item]
        
        if account.containsAsset(assetResult.id) {
            displaySimpleAlertWith(title: "asset-you-already-own-message".localized, message: "")
            return
        }
        
        let assetAlertDraft = AssetAlertDraft(
            account: account,
            assetIndex: assetResult.id,
            assetDetail: AssetDetail(searchResult: assetResult),
            title: "asset-add-confirmation-title".localized,
            detail: "asset-add-warning".localized,
            actionTitle: "title-approve".localized
        )
        
        let controller = open(
            .assetActionConfirmation(assetAlertDraft: assetAlertDraft),
            by: .customPresentWithoutNavigationController(
                presentationStyle: .overCurrentContext,
                transitionStyle: .crossDissolve,
                transitioningDelegate: nil
            )
        ) as? AssetActionConfirmationViewController
        
        controller?.delegate = self
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: layout.current.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == assetResults.count - paginationRequestOffset && hasNext {
            guard let query = assetAdditionView.assetInputView.inputTextField.text else {
                return
            }
            fetchAssets(with: query.isEmpty ? nil : query, isPaginated: true)
        }
    }
}

extension AssetAdditionViewController: AssetAdditionViewDelegate {
    func assetAdditionViewDidTapVerifiedAssetsButton(_ assetAdditionView: AssetAdditionView) {
        updateFilteringOptions(with: .verified)
        
    }
    
    func assetAdditionViewDidTapUnverifiedAssetsButton(_ assetAdditionView: AssetAdditionView) {
        updateFilteringOptions(with: .unverified)
    }
    
    private func updateFilteringOptions(with filterOption: AssetSearchFilter) {
        if !assetSearchFilters.canToggle(filterOption) {
            return
        }
        
        assetSearchFilters.toggle(filterOption)
        viewModel.update(assetAdditionView, with: assetSearchFilters)
        resetPagination()
        
        let query = assetAdditionView.assetInputView.inputTextField.text
        fetchAssets(with: query, isPaginated: false)
    }
}

extension AssetAdditionViewController: InputViewDelegate {
    func inputViewDidReturn(inputView: BaseInputView) {
        view.endEditing(true)
    }
    
    func inputViewDidChangeValue(inputView: BaseInputView) {
        guard let query = assetAdditionView.assetInputView.inputTextField.text else {
            return
        }
        resetPagination()
        fetchAssets(with: query, isPaginated: false)
    }
    
    private func resetPagination() {
        hasNext = false
        searchOffset = 0
    }
}

extension AssetAdditionViewController: AssetActionConfirmationViewControllerDelegate {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmedActionFor assetDetail: AssetDetail
    ) {
        guard let id = assetDetail.id else {
            return
        }
        
        let assetTransactionDraft = AssetTransactionSendDraft(from: account, assetIndex: id)
        transactionController?.setAssetTransactionDraft(assetTransactionDraft)
        transactionController?.composeAssetTransactionData(transactionType: .assetAddition)
    }
}

extension AssetAdditionViewController: TransactionControllerDelegate {
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: Error) {
        switch error {
        case let .custom(fee):
            guard let api = api,
                let feeValue = fee as? Int64,
                let feeString = feeValue.toAlgos.toDecimalStringForLabel else {
                return
            }
            
            let pushNotificationController = PushNotificationController(api: api)
            pushNotificationController.showFeedbackMessage(
                "asset-min-transaction-error-title".localized,
                subtitle: String(format: "asset-min-transaction-error-message".localized, feeString)
            )
        default:
            break
        }
    }
    
    func transactionControllerDidComposedAssetTransactionData(
        _ transactionController: TransactionController,
        forTransaction draft: AssetTransactionSendDraft?
    ) {
        guard let assetSearchResult = assetResults.first(where: { item -> Bool in
            guard let assetIndex = draft?.assetIndex else {
                return false
            }
            return item.id == assetIndex
        }) else {
            return
        }
        
        delegate?.assetAdditionViewController(self, didAdd: assetSearchResult, to: account)
        popScreen()
    }
}

extension AssetAdditionViewController {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let cellHeight: CGFloat = 50.0
    }
}
