//
//  AccountDetailViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 26.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import SnapKit

class AssetDetailViewController: BaseViewController {
    
    private lazy var rewardsModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 472.0))
    )
    
    private var account: Account
    private var assetDetail: AssetDetail?
    private var isAlgoDisplay: Bool
    private var currentDollarConversion: Double?
    private let viewModel: AssetDetailViewModel
    var route: Screen?
    
    var transactionsTopConstraint: Constraint?
    
    var headerHeight: CGFloat {
        if isAlgoDisplay {
            return AssetDetailView.LayoutConstants.algosHeaderHeight
        }
        return AssetDetailView.LayoutConstants.assetHeaderHeight
    }
    
    private(set) lazy var assetDetailView = AssetDetailView()
    
    private lazy var assetDetailTitleView = AssetDetailTitleView(title: account.name)
    
    private lazy var transactionsViewController = TransactionsViewController(
        account: account,
        configuration: configuration,
        assetDetail: assetDetail
    )
    
    init(account: Account, configuration: ViewControllerConfiguration, assetDetail: AssetDetail? = nil) {
        self.account = account
        self.assetDetail = assetDetail
        self.isAlgoDisplay = assetDetail == nil
        viewModel = AssetDetailViewModel(account: account, assetDetail: assetDetail)
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        let qrBarButton = ALGBarButtonItem(kind: .qr) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let draft = QRCreationDraft(address: strongSelf.account.address, mode: .address)
            strongSelf.open(.qrGenerator(title: "qr-creation-sharing-title".localized, draft: draft), by: .present)
        }

        rightBarButtonItems = [qrBarButton]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDollarConversion()
        handleDeepLinkRoutingIfNeeded()
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        viewModel.configure(assetDetailView.headerView, with: account, and: assetDetail)
        
        navigationItem.titleView = assetDetailTitleView
        viewModel.configure(assetDetailTitleView, with: account, and: assetDetail)
    }
    
    override func linkInteractors() {
        assetDetailView.delegate = self
    }
    
    override func setListeners() {
        super.setListeners()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didAccountUpdate(notification:)),
            name: .AccountUpdate,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didAccountUpdate(notification:)),
            name: .AuthenticatedUserUpdate,
            object: nil
        )
    }
    
    override func prepareLayout() {
        setupAssetDetaiViewLayout()
        setupTransactionsViewController()
    }
}

extension AssetDetailViewController {
    private func fetchDollarConversion() {
        api?.fetchDollarValue { response in
            switch response {
            case let .success(result):
                if let price = result.price,
                    let doubleValue = Double(price) {
                    self.currentDollarConversion = doubleValue
                }
            case .failure:
                break
            }
        }
    }
}

extension AssetDetailViewController {
    private func setupAssetDetaiViewLayout() {
        view.addSubview(assetDetailView)
        
        assetDetailView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(headerHeight)
        }
    }
    
    private func setupTransactionsViewController() {
        addChild(transactionsViewController)
        view.addSubview(transactionsViewController.view)

        transactionsViewController.view.snp.makeConstraints { make in
            transactionsTopConstraint = make.top.equalTo(assetDetailView.snp.bottom).offset(0.0).constraint
            make.leading.trailing.bottom.equalToSuperview()
        }

        transactionsViewController.delegate = self
        transactionsViewController.didMove(toParent: self)
    }
}

extension AssetDetailViewController {
    private func handleDeepLinkRoutingIfNeeded() {
        if let route = route {
            switch route {
            case .assetDetail:
                self.route = nil
                updateLayout()
            default:
                self.route = nil
                open(route, by: .push, animated: false)
            }
        }
    }
    
    private func updateLayout() {
        guard let account = session?.account(from: account.address) else {
            return
        }
        
        viewModel.configure(assetDetailView.headerView, with: account, and: assetDetail)
        transactionsViewController.updateList()
    }
}

extension AssetDetailViewController {
    @objc
    private func didAccountUpdate(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Account],
            let updatedAccount = userInfo["account"] else {
            return
        }
        
        if account == updatedAccount {
            account = updatedAccount
            updateLayout()
        }
    }
}

extension AssetDetailViewController: TransactionsViewControllerDelegate {
    func transactionsViewController(_ transactionsViewController: TransactionsViewController, didScroll scrollView: UIScrollView) {
        if transactionsViewController.isTransactionListEmpty {
            return
        }
        
        let scrollOffset = scrollView.panGestureRecognizer.translation(in: view).y
        let isScrollDirectionUp = scrollOffset < 0
        
        var offset: CGFloat = 0.0
        
        if isScrollDirectionUp {
            offset = -scrollOffset > headerHeight ? headerHeight : scrollOffset
            if offset == headerHeight || transactionsViewController.view.frame.minY <= 5.0 {
                assetDetailTitleView.animateUp(with: 1.0)
                transactionsTopConstraint?.update(offset: -headerHeight)
                return
            } else {
                assetDetailTitleView.animateUp(with: -scrollOffset / headerHeight)
                scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
            }
        } else {
            if scrollView.contentOffset.y > 0.0 {
                return
            }
            
            offset = scrollOffset > headerHeight ? 0.0 : scrollOffset - headerHeight
            if offset == 0.0 || transactionsViewController.view.frame.minY >= headerHeight {
                assetDetailTitleView.animateDown(with: 1.0)
                transactionsTopConstraint?.update(offset: 0.0)
                return
            } else {
                assetDetailTitleView.animateDown(with: scrollOffset / headerHeight)
                scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
            }
        }
        
        transactionsTopConstraint?.update(offset: offset)
        view.layoutIfNeeded()
    }
    
    func transactionsViewController(_ transactionsViewController: TransactionsViewController, didStopScrolling scrollView: UIScrollView) {
        if transactionsViewController.isTransactionListEmpty {
            return
        }
        
        let isScrollDirectionUp = scrollView.panGestureRecognizer.translation(in: view).y < 0
        
        if isScrollDirectionUp {
            if transactionsViewController.view.frame.minY <= 5.0 {
                return
            }
            
            assetDetailTitleView.animateUp(with: 1.0)
            updateScrollOffset(-self.headerHeight)
            
            if transactionsViewController.view.frame.minY <= 5.0 {
                return
            }
            
            view.layoutIfNeeded()
            scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
        } else {
            if transactionsViewController.view.frame.minY >= headerHeight {
                return
            }
            
            assetDetailTitleView.animateDown(with: 1.0)
            updateScrollOffset(0.0)
        }
    }
    
    private func updateScrollOffset(_ offset: CGFloat) {
        UIView.animate(withDuration: 0.33) {
            self.transactionsTopConstraint?.update(offset: offset)
            self.view.layoutIfNeeded()
        }
    }
}

extension AssetDetailViewController: AssetDetailViewDelegate {
    func assetDetailViewDidTapSendButton(_ assetDetailView: AssetDetailView) {
        if isAlgoDisplay {
            open(.sendAlgosTransactionPreview(account: account, receiver: .initial, isSenderEditable: false), by: .push)
        } else {
            guard let assetDetail = assetDetail else {
                return
            }
            open(
                .sendAssetTransactionPreview(
                    account: account,
                    receiver: .initial,
                    assetDetail: assetDetail,
                    isSenderEditable: false,
                    isMaxTransaction: false
                ),
                by: .push
            )
        }
    }
    
    func assetDetailViewDidTapReceiveButton(_ assetDetailView: AssetDetailView) {
        if isAlgoDisplay {
            let draft = AlgosTransactionRequestDraft(account: account)
            open(.requestAlgosTransaction(isPresented: false, algosTransactionRequestDraft: draft), by: .push)
        } else {
            guard let assetDetail = assetDetail else {
                return
            }
            open(
                .requestAssetTransaction(
                    isPresented: false,
                    assetTransactionRequestDraft: AssetTransactionRequestDraft(account: account, assetDetail: assetDetail)
                ),
                by: .push
            )
        }
    }
    
    func assetDetailView(_ assetDetailView: AssetDetailView, didTrigger dollarValueGestureRecognizer: UILongPressGestureRecognizer) {
        guard let currentDollarAmount = currentDollarConversion else {
            return
        }
        
        let dollarAmountForAccount = account.amount.toAlgos * currentDollarAmount
        
        if dollarValueGestureRecognizer.state != .ended {
            viewModel.setDollarValue(visible: true, in: assetDetailView.headerView, for: dollarAmountForAccount)
        } else {
            viewModel.setDollarValue(visible: false, in: assetDetailView.headerView, for: dollarAmountForAccount)
        }
    }
    
    func assetDetailViewDidTapRewardView(_ assetDetailView: AssetDetailView) {
        open(
            .rewardDetail(account: account),
            by: .customPresent(
                presentationStyle: .custom,
                transitionStyle: nil,
                transitioningDelegate: rewardsModalPresenter
            )
        )
    }
    
    func assetDetailView(_ assetDetailView: AssetDetailView, didTriggerAssetIdCopyValue gestureRecognizer: UILongPressGestureRecognizer) {
        if let id = assetDetail?.id {
            displaySimpleAlertWith(title: "asset-id-copied-title".localized, message: "")
            UIPasteboard.general.string = "\(id)"
        }
    }
}
