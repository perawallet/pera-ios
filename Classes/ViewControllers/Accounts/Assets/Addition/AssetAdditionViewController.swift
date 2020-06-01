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

class AssetAdditionViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AssetAdditionViewControllerDelegate?
    
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
    private var assetSearchFilters = AssetSearchFilter.all
    
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
    
    private lazy var pushNotificationController: PushNotificationController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return PushNotificationController(api: api)
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
        fetchAssets(with: nil, isPaginated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        transactionController.stopBLEScan()
        dismissProgressIfNeeded()
        invalidateTimer()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        navigationItem.title = "title-add-asset".localized
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
        fetchAssets(with: query, isPaginated: false)
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
        fetchAssets(with: query, isPaginated: false)
    }
    
    private func resetPagination() {
        hasNext = false
        searchOffset = 0
    }
    
    func inputViewDidTapAccessoryButton(inputView: BaseInputView) {
        assetAdditionView.assetInputView.rightInputAccessoryButton.isHidden = true
        assetAdditionView.assetInputView.inputTextField.text = nil
        resetPagination()
        fetchAssets(with: nil, isPaginated: false)
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
        transactionController.setTransactionDraft(assetTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)
        
        SVProgressHUD.show(withStatus: "title-loading".localized)
        validateTimer()
    }
}

extension AssetAdditionViewController: TransactionControllerDelegate {
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: Error) {
        if account.type.isLedger() {
            ledgerApprovalViewController?.dismissScreen()
        }
        
        SVProgressHUD.dismiss()
        
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
    
    func transactionController(_ transactionController: TransactionController, didFailBLEConnectionWith state: CBManagerState) {
        guard let errorTitle = state.errorDescription.title,
            let errorSubtitle = state.errorDescription.subtitle else {
                return
        }
        
        pushNotificationController.showFeedbackMessage(errorTitle, subtitle: errorSubtitle)
        
        invalidateTimer()
        dismissProgressIfNeeded()
    }
    
    func transactionController(_ transactionController: TransactionController, didFailToConnect peripheral: CBPeripheral) {
        pushNotificationController.showFeedbackMessage("ble-error-connection-title".localized,
                                                       subtitle: "ble-error-fail-connect-peripheral".localized)
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
        
        if account.type.isLedger() {
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
        pushNotificationController.showFeedbackMessage("ble-error-transaction-cancelled-title".localized,
                                                       subtitle: "ble-error-fail-sign-transaction".localized)
    }
}

// MARK: Ledger Timer
extension AssetAdditionViewController {
    func validateTimer() {
        guard account.type.isLedger() else {
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
                self.pushNotificationController.showFeedbackMessage(
                    "ble-error-connection-title".localized,
                    subtitle: "ble-error-fail-connect-peripheral".localized
                )
            }
            
            self.invalidateTimer()
        }
    }
    
    func invalidateTimer() {
        guard account.type.isLedger() else {
            return
        }
        
        timer?.invalidate()
        timer = nil
    }
}

extension AssetAdditionViewController {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let cellHeight: CGFloat = 50.0
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
