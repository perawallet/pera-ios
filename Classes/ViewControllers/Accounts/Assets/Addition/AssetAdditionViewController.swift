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
        didAdd assetDetail: AssetDetail,
        to account: Account
    )
}

class AssetAdditionViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: AssetAdditionViewControllerDelegate?
    
    private var account: Account
    private var assetResults = [AssetQueryItem]()
    private lazy var assetAdditionView = AssetAdditionView()
    
    private lazy var emptyStateView = EmptyStateView(title: "asset-not-found".localized, topImage: nil, bottomImage: nil)
    
    private let viewModel = AssetAdditionViewModel()
    
    init(account: Account, configuration: ViewControllerConfiguration) {
        self.account = account
        super.init(configuration: configuration)
        hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAssets(with: "")
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        navigationItem.title = "title-add-asset".localized
    }
    
    override func setListeners() {
        assetAdditionView.assetInputView.delegate = self
        assetAdditionView.assetsCollectionView.delegate = self
        assetAdditionView.assetsCollectionView.dataSource = self
        transactionManager?.delegate = self
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
    private func fetchAssets(with assetId: String) {
        let assetFetchDraft = AssetFetchDraft(assetId: assetId)
        api?.getAssets(with: assetFetchDraft) { [unowned self] response in
            switch response {
            case let .success(assetList):
                self.assetResults = assetList.assets
                self.assetResults.forEach { result in
                    result.assetDetail.index = "\(result.index)"
                }
                
                if self.assetResults.isEmpty {
                    self.assetAdditionView.assetsCollectionView.contentState = .empty(self.emptyStateView)
                } else {
                    self.assetAdditionView.assetsCollectionView.contentState = .none
                }
                
                self.assetAdditionView.assetsCollectionView.reloadData()
            case .failure:
                break
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
        viewModel.configure(cell, with: assetResult.assetDetail)
        
        return cell
    }
}

extension AssetAdditionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let assetResult = assetResults[indexPath.item]
        
        if account.assetDetails.contains(assetResult.assetDetail) {
            displaySimpleAlertWith(title: "asset-you-already-own-message".localized, message: "")
            return
        }
        
        let assetAlertDraft = AssetAlertDraft(
            account: account,
            assetDetail: assetResult.assetDetail,
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
}

extension AssetAdditionViewController: InputViewDelegate {
    func inputViewDidReturn(inputView: BaseInputView) {
        view.endEditing(true)
    }
    
    func inputViewDidChangeValue(inputView: BaseInputView) {
        if assetResults.isEmpty {
            assetAdditionView.assetsCollectionView.contentState = .empty(emptyStateView)
            return
        }
        
        guard let query = assetAdditionView.assetInputView.inputTextField.text else {
            return
        }
        
        fetchAssets(with: query)
    }
}

extension AssetAdditionViewController: AssetActionConfirmationViewControllerDelegate {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmedActionFor assetDetail: AssetDetail
    ) {
        guard let index = assetDetail.index,
            let indexIntValue = Int64(index) else {
                return
        }
        
        let assetTransactionDraft = AssetTransactionDraft(fromAccount: account, recipient: nil, amount: nil, assetIndex: indexIntValue)
        transactionManager?.setAssetTransactionDraft(assetTransactionDraft)
        transactionManager?.composeAssetAdditionTransactionData(for: account)
    }
}

extension AssetAdditionViewController: TransactionManagerDelegate {
    func transactionManager(_ transactionManager: TransactionManager, didFailedComposing error: Error) {
        switch error {
        case .custom:
            guard let api = api else {
                return
            }
            let pushNotificationController = PushNotificationController(api: api)
            pushNotificationController.showFeedbackMessage(
                "asset-min-transaction-error-title".localized,
                subtitle: "asset-min-transaction-error-message".localized
            )
        default:
            break
        }
    }
    
    func transactionManagerDidComposedAssetTransactionData(
        _ transactionManager: TransactionManager,
        forTransaction draft: AssetTransactionDraft?
    ) {
        guard let assetQueryItem = assetResults.first(where: { item -> Bool in
            guard let assetIndex = draft?.assetIndex else {
                return false
            }
            return item.index == assetIndex
        }) else {
            return
        }
        
        delegate?.assetAdditionViewController(self, didAdd: assetQueryItem.assetDetail, to: account)
        popScreen()
    }
}

extension AssetAdditionViewController {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let cellHeight: CGFloat = 50.0
    }
}
