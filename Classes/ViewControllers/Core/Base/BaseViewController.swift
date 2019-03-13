//
//  BaseViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 13.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    // MARK: Properties
    
    private(set) var isViewFirstLoaded = true
    private(set) var isViewAppearing = false
    private(set) var isViewAppeared = false
    private(set) var isViewDisappearing = false
    private(set) var isViewDisappeared = false
    
    // MARK: Initialization
    
    init() {
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
        
        configureAppearance()
        prepareLayout()
        linkInteractors()
        setListeners()
    }
    
    func configureAppearance() {
    }
    
    func prepareLayout() {
    }
    
    func linkInteractors() {
    }
    
    func setListeners() {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        isViewFirstLoaded = false
        isViewAppeared = false
        isViewDisappearing = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        isViewDisappearing = false
        isViewDisappeared = true
    }
}
