// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  AssetAdditionViewController.swift

import UIKit
import MagpieHipo
import MagpieExceptions

final class AssetAdditionViewController: PageContainer, TestNetTitleDisplayable {
    weak var delegate: AssetAdditionViewControllerDelegate?

    private lazy var theme = Theme()

    private lazy var assetActionConfirmationPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(theme.assetActionConfirmationModalSize))
    )
    
    private var account: Account
    
    private var assetResults = [AssetSearchResult]()
    private var nextCursor: String?
    private var hasNext: Bool {
        return nextCursor != nil
    }

    private let paginationRequestOffset = 3
    private var assetSearchFilter: AssetSearchFilter = .verified
    
    private lazy var transactionController: TransactionController = {
        guard let api = api else {
            fatalError("API should be set.")
        }
        return TransactionController(api: api, bannerController: bannerController)
    }()

    private lazy var assetSearchInput = SearchInputView()

    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        addBarButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        transactionController.stopBLEScan()
        loadingController?.stopLoading()
        transactionController.stopTimer()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        setPrimaryBackgroundColor()
        displayTestNetTitleView(with: "title-add-asset".localized)
    }

    override func prepareLayout() {
        addAssetSearchInput()
        super.prepareLayout()
    }

    override func addPageBar() {
        view.addSubview(pageBar)
        pageBar.prepareLayout(PageBarCommonLayoutSheet())
        pageBar.snp.makeConstraints {
            $0.top.equalTo(assetSearchInput.snp.bottom).offset(theme.topPadding)
            $0.leading.trailing.equalToSuperview()
        }
    }

    override func itemDidSelect(_ index: Int) {
        assetSearchFilter = index == 0 ? .verified : .all
        resetPagination()

        let query = assetSearchInput.text
        fetchAssets(query: query, isPaginated: false)
    }

    private lazy var verifiedAssetsScreen = AssetListViewController(configuration: configuration)
    private lazy var allAssetsScreen = AssetListViewController(configuration: configuration)

    override func linkInteractors() {
        super.linkInteractors()

        assetSearchInput.delegate = self
        transactionController.delegate = self
        verifiedAssetsScreen.delegate = self
        allAssetsScreen.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAssets(query: nil, isPaginated: false)

        items = [
            VerifiedAssetsPageBarItem(screen: verifiedAssetsScreen),
            AllAssetsPageBarItem(screen: allAssetsScreen)
        ]
    }
}

extension AssetAdditionViewController {
    private func addBarButtons() {
        let infoBarButton = ALGBarButtonItem(kind: .info) { [weak self] in
            self?.open(.verifiedAssetInformation, by: .present)
        }

        rightBarButtonItems = [infoBarButton]
    }
}

extension AssetAdditionViewController {
    private func addAssetSearchInput() {
        assetSearchInput.customize(theme.searchInputViewTheme)
        view.addSubview(assetSearchInput)
        assetSearchInput.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.topPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }
}

extension AssetAdditionViewController {
    private func resetPagination() {
        nextCursor = nil
    }
}

extension AssetAdditionViewController: AssetListViewControllerDelegate {
    func assetListViewController(_ assetListViewController: AssetListViewController, willDisplayItemAt indexPath: IndexPath) {
        if indexPath.item == assetResults.count - paginationRequestOffset && hasNext {
            guard let query = assetSearchInput.text else {
                return
            }
            fetchAssets(query: query.isEmpty ? nil : query, isPaginated: true)
        }
    }
}

extension AssetAdditionViewController {
    private func fetchAssets(query: String?, isPaginated: Bool) {
        let searchDraft = AssetSearchQuery(status: assetSearchFilters, query: query, cursor: nextCursor)
        api?.searchAssets(searchDraft) { [weak self] response in
            switch response {
            case let .success(searchResults):
                guard let self = self else {
                    return
                }

                if isPaginated {
                    self.assetResults.append(contentsOf: searchResults.results)
                } else {
                    self.assetResults = searchResults.results
                }

                self.nextCursor = searchResults.parsePaginationCursor()
                self.render(for: self.assetSearchFilter, with: self.assetResults)
            case .failure:
                guard let self = self else {
                    return
                }
                self.render(for: self.assetSearchFilter, with: self.assetResults)
            }
        }
    }
}

extension AssetAdditionViewController {
    func render(for filter: AssetSearchFilter, with assets: [AssetSearchResult]) {
        switch filter {
        case .all:
            allAssetsScreen.assetResults = assets
        case .verified:
            verifiedAssetsScreen.assetResults = assets
        default:
            break
        }
    }
}

extension AssetAdditionViewController: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        resetPagination()
        fetchAssets(query: view.text, isPaginated: false)
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
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

        loadingController?.startLoadingWithMessage("title-loading".localized)
        
        if account.requiresLedgerConnection() {
            transactionController.initializeLedgerTransactionAccount()
            transactionController.startTimer()
        }
    }

    func assetListViewController(_ assetListViewController: AssetListViewController, didSelectItemAt indexPath: IndexPath) {
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
            actionTitle: "title-approve".localized,
            cancelTitle: "title-cancel".localized
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
}

extension AssetAdditionViewController: TransactionControllerDelegate {
    func transactionController(_ transactionController: TransactionController, didFailedComposing error: HIPError<TransactionError, HIPAPIErrorDetail>) {
        loadingController?.stopLoading()
        
        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        default:
            break
        }
    }

    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPError<TransactionError>) {
        loadingController?.stopLoading()
        switch error {
        case let .network(apiError):
            bannerController?.presentErrorBanner(title: "title-error".localized, message: apiError.debugDescription)
        default:
            bannerController?.presentErrorBanner(title: "title-error".localized, message: error.localizedDescription)
        }
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
        
        delegate?.assetAdditionViewController(self, didAdd: assetSearchResult, to: account)
        popScreen()
    }

    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            bannerController?.presentErrorBanner(
                title: "asset-min-transaction-error-title".localized,
                message: "asset-min-transaction-error-message".localized(params: amount.toAlgos.toAlgosStringForLabel ?? "")
            )
        case .invalidAddress:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "send-algos-receiver-address-validation".localized
            )
        case let .sdkError(error):
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error.debugDescription
            )
        default:
            break
        }
    }
    
    func transactionController(_ transactionController: TransactionController, didFailedTransaction error: HIPTransactionError) {
        loadingController?.stopLoading()
        switch error {
        case let .network(apiError):
            bannerController?.presentErrorBanner(title: "title-error".localized, message: apiError.debugDescription)
        default:
            bannerController?.presentErrorBanner(title: "title-error".localized, message: error.localizedDescription)
        }
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
        
        delegate?.assetAdditionViewController(self, didAdd: assetSearchResult, to: account)
        popScreen()
    }
}

extension AssetAdditionViewController {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let itemHeight: CGFloat = 52.0
        let multiItemHeight: CGFloat = 72.0
        let modalHeight: CGFloat = 510.0
    }
}

protocol AssetAdditionViewControllerDelegate: AnyObject {
    func assetAdditionViewController(
        _ assetAdditionViewController: AssetAdditionViewController,
        didAdd assetSearchResult: AssetSearchResult,
        to account: Account
    )
}
