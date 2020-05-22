//
//  BaseViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    var isStatusBarHidden: Bool = false
    var hidesStatusBarWhenAppeared: Bool = false
    var hidesStatusBarWhenPresented: Bool = false
    
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
        beginTracking()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        endTracking()
    }
    
    func configureNavigationBarAppearance() {
    }
    
    func beginTracking() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didChangedNetwork(notification:)),
            name: .NetworkChanged,
            object: nil
        )
    }

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
        
        isViewDisappeared = false
        isViewAppearing = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewAppearing = false
        isViewAppeared = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setNeedsStatusBarLayoutUpdateWhenDisappearing()
        
        isViewFirstLoaded = false
        isViewAppeared = false
        isViewDisappearing = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isViewDisappearing = false
        isViewDisappeared = true
    }
    
    private func setNeedsNavigationBarAppearanceUpdateWhenAppearing() {
        navigationController?.setNavigationBarHidden(!shouldShowNavigationBar, animated: false)
    }
    
    func didTapBackBarButton() -> Bool {
        return true
    }
    
    func didTapDismissBarButton() -> Bool {
        return true
    }
    
    @objc
    private func didChangedNetwork(notification: Notification) {
        setNeedsStatusBarAppearanceUpdate()
    }
}

extension BaseViewController {
    func addTestNetBanner() {
        guard let api = api, api.isTestNet else {
            return
        }
        
        if #available(iOS 13.0, *) {
            let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
            
            let statusbarView = UIView()
            statusbarView.layer.zPosition = 1
            statusbarView.backgroundColor = SharedColors.testNetBanner
            navigationController?.view.addSubview(statusbarView)
          
            statusbarView.translatesAutoresizingMaskIntoConstraints = false
            
            statusbarView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.height.equalTo(statusBarHeight)
                make.top.leading.trailing.equalToSuperview()
            }
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = SharedColors.testNetBanner
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
