//
//  HistoryViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class HistoryViewController: BaseScrollViewController {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let topInset: CGFloat = 10.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Variables
    
    private lazy var accountListModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        )
    )
    
    // MARK: Components
    
    private lazy var historyView: HistoryView = {
        let view = HistoryView()
        return view
    }()
    
    private var selectedAccount: Account?
    
    private let viewModel = HistoryViewModel()
    
    // MARK: Setup
    
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
    
    private func setupHistoryViewLayout() {
        contentView.addSubview(historyView)
        
        historyView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.topInset)
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: Navigation
    
    private func presentAccountList() {
        let accountListViewController = open(
            .accountList(mode: .onlyList),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: accountListModalPresenter
            )
        ) as? AccountListViewController
        
        accountListViewController?.delegate = self
    }
}

// MARK: HistoryViewDelegate

extension HistoryViewController: HistoryViewDelegate {
    
    func historyViewDidTapViewResultsButton(_ historyView: HistoryView) {
        guard let startDate = historyView.startDate,
            let endDate = historyView.endDate,
            let account = selectedAccount else {
                displaySimpleAlertWith(title: "history-alert-title".localized, message: "history-alert-message".localized)
                return
        }
        
        let historyDraft = HistoryDraft(account: account, startDate: startDate, endDate: endDate)
        
        open(.historyResults(draft: historyDraft), by: .push)
    }
    
    func historyViewDidTapAccountSelectionView(_ historyView: HistoryView) {
        presentAccountList()
    }
}

// MARK: AccountListViewControllerDelegate

extension HistoryViewController: AccountListViewControllerDelegate {
    
    func accountListViewControllerDidTapAddButton(_ viewController: AccountListViewController) {
    }
    
    func accountListViewController(_ viewController: AccountListViewController, didSelectAccount account: Account) {
        viewModel.configure(historyView, with: account)
        
        selectedAccount = account
    }
}
