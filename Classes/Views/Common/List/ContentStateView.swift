//
//  ContentStateView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 29.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class ContentStateView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let loadingIndicatorInset: CGFloat = 50.0
    }
    
    private let layout = Layout<LayoutConstants>()

    var state = State.none {
        didSet {
            if state == oldValue {
                return
            }
            
            updateAppearance()
        }
    }
    
    // MARK: Components
    
    var onContentStateChanged: ((State) -> Void)?
    
    private lazy var contentView = UIView()
    
    private var emptyStateView: UIView?
    
    private lazy var loadingIndicator = LoadingIndicator()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .clear
        updateAppearance()
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupContentViewLayout()
        setupLoadingIndicatorLayout()
    }
    
    private func setupContentViewLayout() {
        addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupLoadingIndicatorLayout() {
        contentView.addSubview(loadingIndicator)
        
        loadingIndicator.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(layout.current.loadingIndicatorInset)
        }
    }
    
    // MARK: Updates
    
    private func updateAppearance() {
        switch state {
        case .none:
            setLoadingIndicator(visible: false)
            setEmpty(emptyStateView, visible: false)
        case .loading:
            setLoadingIndicator(visible: true)
            setEmpty(emptyStateView, visible: false)
        case let .empty(emptyView):
            setLoadingIndicator(visible: false)
            setEmpty(emptyView, visible: true)
        case .unexpectedError:
            break
        }
    }
    
    private func setEmpty(_ emptyView: UIView?, visible: Bool) {
        if visible {
            if emptyStateView == emptyView {
                return
            }
            
            guard let view = emptyView else {
                emptyStateView?.removeFromSuperview()
                emptyStateView = nil
                return
            }
            
            contentView.addSubview(view)
            
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            emptyStateView = emptyView
            
            return
        }
        
        self.emptyStateView = nil
        emptyView?.removeFromSuperview()
    }
    
    private func setLoadingIndicator(visible: Bool) {
        if visible {
            loadingIndicator.show()
        } else {
            loadingIndicator.dismiss()
        }
    }

}

// MARK: State

extension ContentStateView {
    
    enum State: Equatable {
        case none
        case loading
        case empty(UIView)
        case unexpectedError(UIView)
    }
}
