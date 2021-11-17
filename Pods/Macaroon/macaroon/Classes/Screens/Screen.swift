// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

open class Screen:
    UIViewController,
    StatusBarConfigurable,
    NavigationBarConfigurable,
    ScreenComposable,
    ScreenRoutable,
    UIAdaptivePresentationControllerDelegate,
    NotificationObserver {
    public var statusBarHidden = false
    public var hidesStatusBarOnAppeared = false
    public var hidesStatusBarOnPresented = false

    public var navigationBarHidden = false
    public var hidesCloseBarButton = false
    public var hidesDismissBarButtonIniOS13AndLater = false
    public var disablesInteractivePop = false
    public var disablesInteractiveDismiss = false {
        didSet {
            if #available(iOS 13.0, *) {
                isModalInPresentation = disablesInteractiveDismiss
            }
        }
    }

    public var leftNavigationBarButtonItems: [NavigationBarButtonItem] = []
    public var rightNavigationBarButtonItems: [NavigationBarButtonItem] = []

    public var observations: [NSObjectProtocol] = []

    public var flowIdentifier: String = ""
    public var pathIdentifier: String = ""

    public private(set) var isViewFirstAppeared = true
    public private(set) var isViewAppearing = false
    public private(set) var isViewAppeared = false
    public private(set) var isViewDisappearing = false
    public private(set) var isViewDisappeared = false
    public private(set) var isViewDismissed = false
    public private(set) var isViewPopped = false

    open override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return statusBarHidden ? .fade : .none
    }

    public let configurator: ScreenConfigurable?

    public init(
        configurator: ScreenConfigurable?
    ) {
        self.configurator = configurator

        super.init(
            nibName: nil,
            bundle: nil
        )

        configureNavigationBar()
        observeNotifications()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        unobserveNotifications()
    }

    open func observeNotifications() {}

    public func observeApplicationLifeCycleNotifications() {
        notifyWhenApplicationWillEnterForeground {
            [unowned self] _ in

            self.viewWillEnterForeground()
        }
        notifyWhenApplicationDidEnterBackground {
            [unowned self] _ in

            self.viewDidEnterBackground()
        }
    }

    open func configureNavigationBar() {
        customizeNavigationBarTitle()
        customizeNavigationBarLeftBarButtons()
        customizeNavigationBarRightBarButtons()

        if isViewLoaded {
            setNeedsNavigationBarAppearanceUpdate()
        }
    }

    open func customizeNavigationBarTitle() {}
    open func customizeNavigationBarLeftBarButtons() {}
    open func customizeNavigationBarRightBarButtons() {}

    open func makePopNavigationBarButtonItem() -> NavigationBarButtonItem {
        guard let item = configurator?.makePopNavigationBarButtonItem() else {
            mc_crash(
                .popNavigationBarButtonItemNotFound
            )
        }

        return item
    }

    open func makeDismissNavigationBarButtonItem() -> NavigationBarButtonItem {
        guard let item = configurator?.makeDismissNavigationBarButtonItem() else {
            mc_crash(
                .dismissNavigationBarButtonItemNotFound
            )
        }

        return item
    }

    open func customizeAppearance() {
        configurator?.viewCustomizeAppearance()
    }

    open func customizeViewAppearance(
        _ style: ViewStyle
    ) {
        view.customizeAppearance(
            style
        )
        navigationController?.view.customizeAppearance(
            style
        )
    }

    open func prepareLayout() {}
    open func updateLayoutWhenViewDidLayoutSubviews() {}

    open func setListeners() {}
    open func linkInteractors() {}

    open func bindData() {}

    open func viewDidAttemptInteractiveDismiss() {
        configurator?.viewDidAttemptInteractiveDismiss()
    }

    open func viewDidAppearAfterInteractiveDismiss() {
        isViewFirstAppeared = false

        if let parentScreen = parent as? Screen {
            parentScreen.viewDidAppearAfterInteractiveDismiss()
        }

        configurator?.viewDidAppearAfterInteractiveDismiss()
    }

    open func viewDidChangePreferredUserInterfaceStyle() {
        configurator?.viewDidChangePreferredUserInterfaceStyle()
    }

    open func viewDidChangePreferredContentSizeCategory() {
        configurator?.viewDidChangePreferredContentSizeCategory()
    }

    open func viewWillEnterForeground() {
        configurator?.viewWillEnterForeground()
    }

    open func viewDidEnterBackground() {
        if isViewAppeared {
            isViewFirstAppeared = false
        }

        configurator?.viewDidEnterBackground()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        setNeedsNavigationBarAppearanceUpdate()
        compose()

        configurator?.viewDidLoad()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayoutWhenViewDidLayoutSubviews()

        configurator?.viewDidLayoutSubviews()
    }

    open override func viewWillAppear(
        _ animated: Bool
    ) {
        super.viewWillAppear(
            animated
        )

        setNeedsStatusBarAppearanceUpdateOnBeingAppeared()
        setNeedsNavigationBarAppearanceUpdateOnBeingAppeared()

        disablesInteractivePop = navigationBarHidden || hidesCloseBarButton

        isViewDisappearing = false
        isViewDisappeared = false
        isViewAppearing = true

        configurator?.viewWillAppear()
    }

    open override func viewDidAppear(
        _ animated: Bool
    ) {
        super.viewDidAppear(
            animated
        )

        isViewAppearing = false
        isViewAppeared = true

        configurator?.viewDidAppear()
    }

    open override func viewWillDisappear(
        _ animated: Bool
    ) {
        super.viewWillDisappear(animated)

        setNeedsStatusBarAppearanceUpdateOnBeingDisappeared()

        isViewFirstAppeared = false
        isViewAppeared = false
        isViewDisappearing = true
        isViewDismissed = isBeingDismissed
        isViewPopped = isMovingFromParent

        configurator?.viewWillDisappear()
    }

    open override func viewDidDisappear(
        _ animated: Bool
    ) {
        super.viewDidDisappear(
            animated
        )

        isViewDisappearing = false
        isViewDisappeared = true

        configurator?.viewDidDisappear()
    }

    open override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(
            previousTraitCollection
        )

        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                viewDidChangePreferredUserInterfaceStyle()
            }
        }

        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            viewDidChangePreferredContentSizeCategory()
        }
    }

    /// <mark>
    /// UIAdaptivePresentationControllerDelegate
    open func presentationControllerDidDismiss(
        _ presentationController: UIPresentationController
    ) {
        viewDidAppearAfterInteractiveDismiss()
    }

    open func presentationControllerDidAttemptToDismiss(
        _ presentationController: UIPresentationController
    ) {
        guard var presentingScreen = presentingViewController else {
            return
        }

        if let presentingNavigationContainer = presentingScreen as? UINavigationController,
           let presentingNavigationScreen = presentingNavigationContainer.viewControllers.last {
            presentingScreen = presentingNavigationScreen
        }

        guard let configurablePresentingScreen = presentingScreen as? Screen else {
            return
        }

        configurablePresentingScreen.viewDidAttemptInteractiveDismiss()
    }
}
