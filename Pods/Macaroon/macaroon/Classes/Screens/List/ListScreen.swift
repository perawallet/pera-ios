// Copyright © 2019 hipolabs. All rights reserved.

import Foundation
import SnapKit
import UIKit

open class ListScreen: Screen, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, EmptyStateViewDataSource {
    public lazy var listView = ListView(listLayout: listLayout)

    public let listDataSource: ListDataSource
    public let listLayout: ListLayout

    private var isListLayoutFinalized = false

    public init(
        listDataSource: ListDataSource,
        listLayout: ListLayout,
        configurator: ScreenConfigurable?
    ) {
        self.listDataSource = listDataSource
        self.listLayout = listLayout

        super.init(
            configurator: configurator
        )
    }

    open override func customizeAppearance() {
        super.customizeAppearance()
        customizeListAppearance()
    }

    open func customizeListAppearance() {
        listView.alwaysBounceVertical = true
        listView.showsHorizontalScrollIndicator = false
        listView.showsVerticalScrollIndicator = false
    }

    open override func prepareLayout() {
        super.prepareLayout()
        addList()
        updateListEmptyStateLayout()
    }

    open override func updateLayoutWhenViewDidLayoutSubviews() {
        super.updateLayoutWhenViewDidLayoutSubviews()

        if isListLayoutFinalized {
            return
        }

        updateListLayoutWhenViewDidFirstLayoutSubviews()

        isListLayoutFinalized = true
    }

    open func addList() {
        view.addSubview(listView)
        listView.snp.makeConstraints { maker in
            maker.top.equalTo(view.safeAreaLayoutGuide)
            maker.leading.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.trailing.equalToSuperview()
        }
    }

    private func updateListLayoutWhenViewDidFirstLayoutSubviews() {
        listView.setContentInset(
            listLayout.contentInset
        )
    }

    open override func setListeners() {
        super.setListeners()
        listView.dataSource = self
        listView.delegate = self
        listView.emptyStateDataSource = self
    }

    open override func viewDidChangePreferredContentSizeCategory() {
        super.viewDidChangePreferredContentSizeCategory()

        if !isViewAppeared {
            return
        }

        listLayout.invalidateLayout(forceLayoutUpdate: true)
        updateLayoutWhenViewDidLayoutSubviews()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        listLayout.prepareForUse()
    }

    /// <mark> UICollectionViewDataSource
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return listDataSource.numberOfSections()
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listDataSource.numberOfItems(inSection: section)
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return listLayout.cell(for: listDataSource[indexPath], at: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return listLayout.header(for: listDataSource[indexPath.section], in: indexPath.section)
        case UICollectionView.elementKindSectionFooter:
            return listLayout.footer(for: listDataSource[indexPath.section], in: indexPath.section)
        default:
            mc_crash(.unsupportedListSupplementaryView(UICollectionReusableView.self, kind))
        }
    }

    /// <mark> UICollectionViewDelegateFlowLayout
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return listLayout.size(for: listDataSource[indexPath], at: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if listDataSource.isSectionEmpty(section) &&
           !listLayout.shouldShowHeadersForEmptySection(section) {
            return .zero
        }
        return listLayout.headerSize(for: listDataSource[section], in: section)
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if listDataSource.isSectionEmpty(section) &&
           !listLayout.shouldShowFooterForEmptySection(section) {
            return .zero
        }
        return listLayout.footerSize(for: listDataSource[section], in: section)
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if listDataSource.isSectionEmpty(section) {
            return 0.0
        }
        return listLayout.minimumLineSpacing(for: listDataSource[section], in: section)
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if listDataSource.isSectionEmpty(section) {
            return 0.0
        }
        return listLayout.minimumInteritemSpacing(for: listDataSource[section], in: section)
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if listDataSource.isSectionEmpty(section) {
            return .zero
        }
        return listLayout.sectionInset(for: listDataSource[section], in: section)
    }

    /// <mark> UICollectionViewDelegate
    open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionView.elementKindSectionHeader ||
           elementKind == UICollectionView.elementKindSectionFooter {
            view.layer.zPosition = 0.0
        }
    }

    /// <mark> EmptyStateViewDataSource
    open func loadingIndicator(in view: EmptyStateView) -> LoadingIndicator? {
        let loadingIndicator: UIActivityIndicatorView

        if #available(iOS 13, *) {
            loadingIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            loadingIndicator = UIActivityIndicatorView(style: .gray)
        }
        return loadingIndicator
    }

    open func noContentView(userInfo: Any?, in view: EmptyStateView) -> UIView? {
        return nil
    }

    open func noNetworkView(userInfo: Any?, in view: EmptyStateView) -> UIView? {
        return nil
    }

    open func faultView(userInfo: Any?, in view: EmptyStateView) -> UIView? {
        return nil
    }

    open func contentAlignment(for state: EmptyStateView.State, in view: EmptyStateView) -> EmptyStateView.ContentAlignment {
        return .center(offset: 0, horizontalPaddings: (0, 0))
    }
}

extension ListScreen {
    public func reloadData(
        _ modifier: ListModifier,
        onCompleted execute: (() -> Void)? = nil
    ) {
        listView.reloadData(
            modifier,
            for: listLayout,
            onAppeared: isViewAppeared,
            onCompleted: execute
        )
    }
}

extension ListScreen {
    public func item(for cell: UICollectionViewCell) -> Any? {
        guard let indexPath = listView.indexPath(for: cell) else {
            return nil
        }

        return listDataSource[indexPath]
    }
}

extension ListScreen {
    private func updateListEmptyStateLayout() {
        listView.emptyStateView.frame = view.bounds
    }
}
