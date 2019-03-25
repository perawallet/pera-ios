//
//  BaseViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    // MARK: Configuration
    
    var isStatusBarHidden: Bool = false
    
    var hidesStatusBarWhenAppeared: Bool = false
    
    var hidesStatusBarWhenPresented: Bool = false
    
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
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
    
    // MARK: Properties
    
    private(set) var isViewFirstLoaded = true
    private(set) var isViewAppearing = false
    private(set) var isViewAppeared = false
    private(set) var isViewDisappearing = false
    private(set) var isViewDisappeared = false
    
    let configuration: ViewControllerConfiguration
    
    // MARK: Initialization
    
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
    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNeedsNavigationBarAppearanceUpdate()
        configureAppearance()
        prepareLayout()
        linkInteractors()
        setListeners()
    }
    
    func configureAppearance() {
        view.backgroundColor = SharedColors.warmWhite
        
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.font(.montserrat, withWeight: .bold(size: 12.0)),
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
}

extension BaseViewController: StatusBarConfigurable {
}

// MARK: - API Variables
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
