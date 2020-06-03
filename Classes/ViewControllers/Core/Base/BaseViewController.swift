//
//  BaseViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, TabBarConfigurable {
    var isTabBarHidden = true
    var tabBarSnapshot: UIView?
    
    var isStatusBarHidden: Bool = false
    var hidesStatusBarWhenAppeared: Bool = false
    var hidesStatusBarWhenPresented: Bool = false
    
    private lazy var statusbarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.zPosition = 1.0
        view.backgroundColor = SharedColors.testNetBanner
        return view
    }()
    
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return isStatusBarHidden ? .fade : .none
    }
    
    var leftBarButtonItems: [BarButtonItemRef] = []
    var rightBarButtonItems: [BarButtonItemRef] = []
    
    var hidesCloseBarButtonItem: Bool {
        return false
    }
    
    var shouldShowNavigationBar: Bool {
        return true
    }
    
    private(set) var isViewFirstLoaded = true
    private(set) var isViewAppearing = false
    private(set) var isViewAppeared = false
    private(set) var isViewDisappearing = false
    private(set) var isViewDisappeared = false
    
    let configuration: ViewControllerConfiguration
    
    init(configuration: ViewControllerConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
        configureNavigationBarAppearance()
        customizeTabBarAppearence()
        beginTracking()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        endTracking()
    }
    
    func customizeTabBarAppearence() { }
    
    func configureNavigationBarAppearance() {
    }
    
    func beginTracking() { }

    func endTracking() {
        NotificationCenter.unobserve(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPrimaryBackgroundColor()
        setNeedsNavigationBarAppearanceUpdate()
        linkInteractors()
        setListeners()
        configureAppearance()
        prepareLayout()
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.font(withWeight: .semiBold(size: 16.0)),
            NSAttributedString.Key.foregroundColor: SharedColors.primaryText
        ]
    }
    
    func configureAppearance() {
        view.backgroundColor = SharedColors.primaryBackground
    }
    
    func prepareLayout() {
    }
    
    func linkInteractors() {
    }
    
    func setListeners() {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarLayoutUpdateWhenAppearing()
        setNeedsNavigationBarAppearanceUpdateWhenAppearing()
        setNeedsTabBarAppearanceUpdateOnAppearing()
        displayTestNetBannerIfNeeded()
        
        isViewDisappeared = false
        isViewAppearing = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsTabBarAppearanceUpdateOnAppeared()
        isViewAppearing = false
        isViewAppeared = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setNeedsStatusBarLayoutUpdateWhenDisappearing()
        removeTestNetBanner()
        
        isViewFirstLoaded = false
        isViewAppeared = false
        isViewDisappearing = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setNeedsTabBarAppearanceUpdateOnDisappeared()
        isViewDisappearing = false
        isViewDisappeared = true
    }
    
    private func setNeedsNavigationBarAppearanceUpdateWhenAppearing() {
        navigationController?.setNavigationBarHidden(!shouldShowNavigationBar, animated: true)
    }
    
    func didTapBackBarButton() -> Bool {
        return true
    }
    
    func didTapDismissBarButton() -> Bool {
        return true
    }
}

extension BaseViewController {
    private func displayTestNetBannerIfNeeded() {
        guard let navigationController = navigationController,
            !canDisplayTestNetBanner(on: navigationController),
            !canDisplayTestNetBanner(on: self) else {
                removeTestNetBanner()
                return
        }
        
        addTestNetBanner()
    }
    
    private func canDisplayTestNetBanner(on viewController: UIViewController) -> Bool {
        return viewController.isBeingPresented
            && (viewController.modalPresentationStyle == .custom
            || viewController.modalPresentationStyle == .pageSheet
            || viewController.modalPresentationStyle == .popover)
    }
    
    func addTestNetBanner() {
        guard let api = api, api.isTestNet else {
            removeTestNetBanner()
            return
        }
        
        if statusbarView.superview != nil {
            return
        }
        
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        navigationController?.view.addSubview(statusbarView)
        
        statusbarView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(statusBarHeight)
            make.top.leading.trailing.equalToSuperview()
        }
    }
    
    func removeTestNetBanner() {
        if statusbarView.superview != nil {
            statusbarView.removeFromSuperview()
        }
    }
}

extension BaseViewController {
    func setPrimaryBackgroundColor() {
        navigationController?.navigationBar.barTintColor = SharedColors.primaryBackground
        navigationController?.navigationBar.tintColor = SharedColors.primaryBackground
    }
    
    func setSecondaryBackgroundColor() {
        navigationController?.navigationBar.barTintColor = SharedColors.secondaryBackground
        navigationController?.navigationBar.tintColor = SharedColors.secondaryBackground
    }
}

extension BaseViewController: StatusBarConfigurable {
}

extension BaseViewController {
    var session: Session? {
        return configuration.session
    }
    
    var api: API? {
        return configuration.api
    }
}

extension BaseViewController: NavigationBarConfigurable {
    typealias BarButtonItemRef = ALGBarButtonItem
}
