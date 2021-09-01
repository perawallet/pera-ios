// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public protocol ScreenComposable: UIViewController {
    func customizeAppearance()
    func prepareLayout()
    func updateLayoutWhenViewDidLayoutSubviews()
    /// <note>
    /// Set dataSource(s) & delegate(s)
    func setListeners()
    /// <note>
    /// Link action-target(s)
    func linkInteractors()
    /// <note>
    /// Bind static data
    func bindData()
}

extension ScreenComposable {
    public func updateLayoutWhenViewDidLayoutSubviews() {}
    public func setListeners() {}
    public func linkInteractors() {}
    public func bindData() {}
}

extension ScreenComposable {
    public func compose() {
        customizeAppearance()
        prepareLayout()
        setListeners()
        linkInteractors()
        bindData()
    }
}
