//
//  AssetAdditionViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 11.11.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import Magpie
import CoreBluetooth
import SVProgressHUD

class AssetAdditionViewController: BaseViewController, TestNetTitleDisplayable {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AssetAdditionViewControllerDelegate?
    
    private let layoutBuilder = AssetListLayoutBuilder()
    
    private lazy var assetActionConfirmationPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: layout.current.modalHeight))
    )
    
    private var account: Account
    
    private var assetResults = [AssetSearchResult]()
    private let searchLimit = 50
    private var searchOffset = 0
    private var hasNext = false
    private let paginationRequestOffset = 3
    private var assetSearchFilters = AssetSearchFilter.verified
    
    private lazy var ledgerApprovalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 354.0))
    )
    
    private var ledgerApprovalViewController: LedgerApprovalViewController?
    
    private lazy var transactionController: TransactionController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return TransactionController(api: api)
    }()
    
    private lazy var assetAdditionView = AssetAdditionView()
    
    private lazy var emptyStateView = SearchEmptyView()
    
    private let viewModel = AssetAdditionViewModel()
    
    private var timer: Timer?
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        let infoBarButton = ALGBarButtonItem(kind: .info) { [weak self] in
            self?.open(.verifiedAssetInformation, by: .present)
        }

        rightBarButtonItems = [infoBarButton]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAssets(query: nil, isPaginated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        transactionController.stopBLEScan()
        dismissProgressIfNeeded()
        invalidateTimer()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        displayTestNetTitleView(with: "title-add-asset".localized)
        emptyStateView.setTitle("asset-not-found-title".localized)
        emptyStateView.setDetail("asset-not-found-detail".localized)
    }
    
    override func setListeners() {
        assetAdditionView.delegate = self
        assetAdditionView.assetInputView.delegate = self
        assetAdditionView.assetsCollectionView.delegate = self
        assetAdditionView.assetsCollectionView.dataSource = self
        transactionController.delegate = self
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
    private func fetchAssets(query: String?, isPaginated: Bool) {
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
        let assetResult = assetResults[indexPath.item]
        let assetDetail = AssetDetail(searchResult: assetResult)
        let cell = layoutBuilder.dequeueAssetCells(in: collectionView, cellForItemAt: indexPath, for: assetDetail)
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
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: assetActionConfirmationPresenter
            )
        ) as? AssetActionConfirmationViewController
        
        controller?.delegate = self
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let assetResult = assetResults[indexPath.item]
        let assetDetail = AssetDetail(searchResult: assetResult)
        
        if assetDetail.hasBothDisplayName() {
            return CGSize(width: UIScreen.main.bounds.width, height: layout.current.multiItemHeight)
        } else {
            return CGSize(width: UIScreen.main.bounds.width, height: layout.current.itemHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == assetResults.count - paginationRequestOffset && hasNext {
            guard let query = assetAdditionView.assetInputView.inputTextField.text else {
                return
            }
            fetchAssets(query: query.isEmpty ? nil : query, isPaginated: true)
        }
    }
}

extension AssetAdditionViewController: AssetAdditionViewDelegate {
    func assetAdditionViewDidTapAllAssets(_ assetAdditionView: AssetAdditionView) {
        updateFilteringOptions(with: .all)
    }
    
    func assetAdditionViewDidTapVerifiedAssets(_ assetAdditionView: AssetAdditionView) {
        updateFilteringOptions(with: .verified)
    }
    
    private func updateFilteringOptions(with filterOption: AssetSearchFilter) {
        assetSearchFilters = filterOption
        resetPagination()
        
        let query = assetAdditionView.assetInputView.inputTextField.text
        fetchAssets(query: query, isPaginated: false)
    }
}

extension AssetAdditionViewController: InputViewDelegate {
    func inputViewDidReturn(inputView: BaseInputView) {
        view.endEditing(true)
    }
    
    func inputViewDidChangeValue(inputView: BaseInputView) {
        guard let query = assetAdditionView.assetInputView.inputTextField.text else {
            assetAdditionView.assetInputView.rightInputAccessoryButton.isHidden = false
            return
        }
        
        assetAdditionView.assetInputView.rightInputAccessoryButton.isHidden = query.isEmpty
        
        resetPagination()
        fetchAssets(query: query, isPaginated: false)
    }
    
    private func resetPagination() {
        hasNext = false
        searchOffset = 0
    }
    
    func inputViewDidTapAccessoryButton(inputView: BaseInputView) {
        assetAdditionView.assetInputView.rightInputAccessoryButton.isHidden = true
        assetAdditionView.assetInputView.inputTextField.text = nil
        resetPagination()
        fetchAssets(query: nil, isPaginated: false)
    }
}

extension AssetAdditionViewController: AssetActionConfirmationViewControllerDelegate {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmedActionFor assetDetail: AssetDetail
    ) {
        guard let session = session,
            session.canSignTransaction(for: &account) else {
            return
        }
        
        let assetTransactionDraft = AssetTransactionSendDraft(from: account, assetIndex: assetDetail.id)
        transactionController.setTransactionDraft(assetTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)
        
        SVProgressHUD.show(withStatus: "title-loading".localized)
        validateTimer()
    }
}

extension AssetAdditionViewController: TransactionControllerDelegate {
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: Error) {
        if account.requiresLedgerConnection() {
            ledgerApprovalViewController?.dismissScreen()
        }
        
        SVProgressHUD.dismiss()
        
        switch error {
        case let .custom(errorType):
            guard let transactionError = errorType as? TransactionController.TransactionError else {
                return
            }
            
            displayMinimumTransactionError(from: transactionError)
        default:
            break
        }
    }
    
    private func displayMinimumTransactionError(from transactionError: TransactionController.TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            NotificationBanner.showError(
                "asset-min-transaction-error-title".localized,
                message: "asset-min-transaction-error-message".localized(params: amount.toAlgos.toDecimalStringForLabel ?? "")
            )
        default:
            break
        }
    }
    
    func transactionController(_ transactionController: TransactionController, didFailBLEConnectionWith state: CBManagerState) {
        guard let errorTitle = state.errorDescription.title,
            let errorSubtitle = state.errorDescription.subtitle else {
                return
        }
        NotificationBanner.showError(errorTitle, message: errorSubtitle)
        invalidateTimer()
        dismissProgressIfNeeded()
    }
    
    func transactionController(_ transactionController: TransactionController, didFailToConnect peripheral: CBPeripheral) {
        NotificationBanner.showError("ble-error-connection-title".localized, message: "ble-error-fail-connect-peripheral".localized)
    }
    
    func transactionController(_ transactionController: TransactionController, didDisconnectFrom peripheral: CBPeripheral) {
    }
    
    func transactionController(_ transactionController: TransactionController, didComposedTransactionDataFor draft: TransactionSendDraft?) {
        guard let assetTransactionDraft = draft as? AssetTransactionSendDraft,
            let assetSearchResult = assetResults.first(where: { item -> Bool in
                guard let assetIndex = assetTransactionDraft.assetIndex else {
                    return false
                }
                return item.id == assetIndex
            }) else {
                return
        }
        
        if account.requiresLedgerConnection() {
            ledgerApprovalViewController?.dismissScreen()
        }
        
        delegate?.assetAdditionViewController(self, didAdd: assetSearchResult, to: account)
        popScreen()
    }
    
    func transactionControllerDidStartBLEConnection(_ transactionController: TransactionController) {
        dismissProgressIfNeeded()
        invalidateTimer()
        ledgerApprovalViewController = open(
            .ledgerApproval(mode: .approve),
            by: .customPresent(presentationStyle: .custom, transitionStyle: nil, transitioningDelegate: ledgerApprovalPresenter)
        ) as? LedgerApprovalViewController
    }
    
    func transactionControllerDidFailToSignWithLedger(_ transactionController: TransactionController) {
        ledgerApprovalViewController?.dismissScreen()
        NotificationBanner.showError(
            "ble-error-transaction-cancelled-title".localized,
            message: "ble-error-fail-sign-transaction".localized
        )
    }
}

// MARK: Ledger Timer
extension AssetAdditionViewController {
    func validateTimer() {
        guard account.requiresLedgerConnection() else {
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            DispatchQueue.main.async {
                self.transactionController.stopBLEScan()
                self.dismissProgressIfNeeded()
                NotificationBanner.showError("ble-error-connection-title".localized, message: "ble-error-fail-connect-peripheral".localized)
            }
            
            self.invalidateTimer()
        }
    }
    
    func invalidateTimer() {
        guard account.requiresLedgerConnection() else {
            return
        }
        
        timer?.invalidate()
        timer = nil
    }
}

extension AssetAdditionViewController {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let itemHeight: CGFloat = 52.0
        let multiItemHeight: CGFloat = 72.0
        let modalHeight: CGFloat = 510.0
    }
}

protocol AssetAdditionViewControllerDelegate: class {
    func assetAdditionViewController(
        _ assetAdditionViewController: AssetAdditionViewController,
        didAdd assetSearchResult: AssetSearchResult,
        to account: Account
    )
}
