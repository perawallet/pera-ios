//
//  HistoryViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class HistoryViewController: BaseScrollViewController {
    
    // MARK: Variables
    
    private lazy var accountListModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .backgroundTouch
        )
    )
    
    // MARK: Components
    
    private lazy var historyView: HistoryView = {
        let view = HistoryView()
        return view
    }()
    
    private var selectedAccount: Account?
    private var startDate: Date?
    private var endDate: Date?
    
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
            make.top.equalToSuperview().inset(10.0)
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
        guard let startDate = startDate,
            let endDate = endDate,
            let account = selectedAccount else {
                return
        }
    }
    
    func historyView(_ historyView: HistoryView, didSelectStartDate date: Date) {
        startDate = date
    }
    
    func historyView(_ historyView: HistoryView, didSelectEndDate date: Date) {
        endDate = date
    }
}

// MARK: AccountListViewControllerDelegate

extension HistoryViewController: AccountListViewControllerDelegate {
    
    func accountListViewControllerDidTapAddButton(_ viewController: AccountListViewController) {
    }
    
    func accountListViewController(_ viewController: AccountListViewController, didSelectAccount account: Account) {
        
        selectedAccount = account
    }
}
