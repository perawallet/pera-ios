//
//  HistoryViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class HistoryViewController: BaseScrollViewController {
    
    private lazy var selectionModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        )
    )
    
    private lazy var historyView = HistoryView()
    
    private var selectedAccount: Account? {
        didSet {
            if selectedAccount != nil {
                historyView.setSelectionView(historyView.assetSelectionView, enabled: true)
            }
        }
    }
    
    private var selectedAssetDetail: AssetDetail?
    private var isAlgoSelected = false
    
    private let viewModel = HistoryViewModel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let account = session?.currentAccount {
            selectedAccount = account
            
            viewModel.configure(historyView, with: account)
        }
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        title = "history-title".localized
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        historyView.delegate = self
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        setupHistoryViewLayout()
    }
}

extension HistoryViewController {
    private func setupHistoryViewLayout() {
        contentView.addSubview(historyView)
        
        historyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension HistoryViewController: HistoryViewDelegate {
    func historyViewDidTapViewResultsButton(_ historyView: HistoryView) {
        guard let account = selectedAccount else {
            displaySimpleAlertWith(title: "history-alert-title".localized, message: "history-alert-message".localized)
            return
        }
        
        let startDate = historyView.startDate
        let endDate = historyView.endDate
        let historyDraft: HistoryDraft
        
        if isAlgoSelected {
            historyDraft = HistoryDraft(account: account, startDate: startDate, endDate: endDate, isAlgoSelected: isAlgoSelected)
        } else {
            historyDraft = HistoryDraft(account: account, startDate: startDate, endDate: endDate, assetDetail: selectedAssetDetail)
        }
        
        open(.historyResults(draft: historyDraft), by: .push)
    }
    
    func historyViewDidTapAccountSelectionView(_ historyView: HistoryView) {
        presentAccountList()
    }
    
    func historyViewDidTapAssetSelectionView(_ historyView: HistoryView) {
        presentAssetList()
    }
}

extension HistoryViewController: AccountListViewControllerDelegate {
    func accountListViewController(_ viewController: AccountListViewController, didSelectAccount account: Account) {
        viewModel.configure(historyView, with: account)
        selectedAccount = account
    }
}

extension HistoryViewController: AssetListViewControllerDelegate {
    func assetListViewController(_ viewController: AssetListViewController, didSelectAlgo account: Account) {
        isAlgoSelected = true
        viewModel.configureForAlgos(historyView)
    }
    
    func assetListViewController(_ viewController: AssetListViewController, didSelectAsset assetDetail: AssetDetail) {
        isAlgoSelected = false
        viewModel.configure(historyView, with: assetDetail)
        selectedAssetDetail = assetDetail
    }
}

extension HistoryViewController {
    private func presentAccountList() {
        let accountListViewController = open(
            .accountList(mode: .assetCount),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: selectionModalPresenter
            )
        ) as? AccountListViewController
        
        accountListViewController?.delegate = self
    }
    
    private func presentAssetList() {
        guard let account = selectedAccount else {
            return
        }
        
        let assetListViewController = open(
            .assetList(account: account),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: selectionModalPresenter
            )
        ) as? AssetListViewController
        
        assetListViewController?.delegate = self
    }
}
