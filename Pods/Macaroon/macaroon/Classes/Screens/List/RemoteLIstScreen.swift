// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

open class RemoteListScreen: ListScreen, ListDataLoaderDelegate {
    public var reloadListWhenViewDidAppear = true
    public var reloadListWhenViewWillEnterForeground = true
    public var invalidatesLayoutForReloadingItems = false {
        didSet { listView.invalidatesLayoutForReloadingItems = invalidatesLayoutForReloadingItems }
    }

    public let listDataLoader: ListDataLoader

    private var lastActiveDate: Date?

    private var isViewFirstLoaded = false

    public init(
        listDataLoader: ListDataLoader & ListDataSource,
        listLayout: ListLayout,
        configurator: ScreenConfigurable?
    ) {
        self.listDataLoader = listDataLoader

        super.init(
            listDataSource: listDataLoader,
            listLayout: listLayout,
            configurator: configurator
        )
    }

    open override func observeNotifications() {
        super.observeNotifications()
        observeApplicationLifeCycleNotifications()
    }

    open override func setListeners() {
        super.setListeners()
        listDataLoader.delegate = self
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty {
            return
        }

        /// <note>
        /// Some screens need the layout to be stabilized so that they can calculate the layout of
        /// the data-driven views correctly, i.e. the layouts of the contents of the empty state view.
        if !isViewFirstLoaded {
            listDataLoader.loadList()
            isViewFirstLoaded = true
        }
    }

    open override func viewDidAppear(
        _ animated: Bool
    ) {
        super.viewDidAppear(
            animated
        )

        if reloadListWhenViewDidAppear,
           !isViewFirstAppeared {
            listDataLoader.reloadList()
        }
    }

    open override func viewDidAppearAfterInteractiveDismiss() {
        super.viewDidAppearAfterInteractiveDismiss()

        if reloadListWhenViewDidAppear {
            listDataLoader.reloadList()
        }
    }

    open override func viewWillEnterForeground() {
        super.viewWillEnterForeground()

        if reloadListWhenViewWillEnterForeground {
            if let lastActiveDate = lastActiveDate,
               Date().timeIntervalSince(lastActiveDate) > 24 * 60 * 60 { /// <mark> 1 day
                listDataLoader.loadList()
            } else {
                listDataLoader.reloadList()
            }
        }

        lastActiveDate = nil
    }

    open override func viewDidEnterBackground() {
        super.viewDidEnterBackground()

        if reloadListWhenViewWillEnterForeground {
            lastActiveDate = Date()
        }
    }

    /// <mark> ListDataLoaderDelegate
    open func listDataLoaderWillLoadList(
        _ dataLoader: ListDataLoader
    ) {
        if !listDataSource.isEmpty() {
            return
        }

        switch listView.emptyState {
        case .none,
             .noNetwork,
             .fault:
            listView.emptyState = .loading
        default: break
        }
    }

    open func listDataLoader(
        _ dataLoader: ListDataLoader,
        didLoadList modifier: ListModifier
    ) {
        reloadData(
            modifier
        ) { [unowned self] in

            self.listView.emptyState =
                self.listDataSource.isEmpty()
                ? .noContent()
                : .none
        }
    }

    open func listDataLoader(
        _ dataLoader: ListDataLoader,
        didFailToLoadList error: ListError
    ) {
        switch error.reason {
        case .network:
            listDataLoader.unloadList()
            listView.emptyState = .noNetwork(userInfo: error.userInfo)
        default:
            listView.emptyState =
                listDataSource.isEmpty()
                ? .fault(userInfo: error.userInfo)
                : .none
        }
    }

    open func listDataLoaderWillLoadNextList(
        _ dataLoader: ListDataLoader
    ) {}

    open func listDataLoader(
        _ dataLoader: ListDataLoader,
        didLoadNextList modifier: ListModifier
    ) {
        reloadData(
            modifier
        )
    }

    open func listDataLoader(
        _ dataLoader: ListDataLoader,
        didFailToLoadNextList error: ListError
    ) {
        switch error.reason {
        case .network:
            dataLoader.unloadList()
            listView.emptyState = .noNetwork(userInfo: error.userInfo)
        default:
            break
        }
    }

    open func listDataLoaderDidUnloadList(
        _ dataLoader: ListDataLoader
    ) {
        reloadData(
            .reload
        )
    }

    /// <mark> UIScrollViewDelegate
    open func scrollViewDidScroll(
        _ scrollView: UIScrollView
    ) {
        let contentHeight = scrollView.contentSize.height
        let scrollHeight = scrollView.bounds.height

        if contentHeight <= scrollHeight ||
           contentHeight - scrollView.contentOffset.y < 2 * scrollHeight {
            listDataLoader.loadNextList()
            return
        }
    }
}
