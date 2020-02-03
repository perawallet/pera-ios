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
    }

    func endTracking() {
        NotificationCenter.unobserve(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNeedsNavigationBarAppearanceUpdate()
        linkInteractors()
        setListeners()
        configureAppearance()
        prepareLayout()
    }
    
    func configureAppearance() {
        view.backgroundColor = SharedColors.warmWhite
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.font(.overpass, withWeight: .semiBold(size: 16.0)),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
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
    
    var transactionController: TransactionController? {
        return configuration.transactionController
    }
}

extension BaseViewController: NavigationBarConfigurable {
    typealias BarButtonItemRef = ALGBarButtonItem
}
