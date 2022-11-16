// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WebNoContentView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class WebNoContentView:
    MacaroonUIKit.BaseView,
    UIInteractable {
    var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .retry : UIBlockInteraction()
    ]

    private lazy var contentView = UIView()

    private var state: State?
    private var contextView: UIView?

    init(_ theme: WebNoContentViewTheme = .init()) {
        super.init(frame: .zero)
        addUI(theme)
    }
}

extension WebNoContentView {
    func setState(
        _ state: State?,
        animated: Bool
    ) {
        updateUI(
            for: state,
            animated: animated
        ) { [weak self] isCompleted in
            guard let self else { return }

            if isCompleted {
                self.state = state
            }
        }
    }
}

extension WebNoContentView {
    private func addUI(_ theme: WebNoContentViewTheme) {
        addBackground(theme)
        addContent(theme)
    }

    typealias UpdateUICompletion = (Bool) -> Void
    private func updateUI(
        for someState: State?,
        animated: Bool,
        completion: @escaping UpdateUICompletion
    ) {
        if someState == state {
            updateUIForOldState(completion: completion)
        } else {
            updateUIForNewState(
                someState,
                animated: animated,
                completion: completion
            )
        }
    }

    private func updateUIForOldState(completion: UpdateUICompletion) {
        defer { completion(true) }

        guard let contextView else { return }

        if let loadingView = contextView as? WebLoadingView {
            loadingView.startAnimating()
        }
    }

    private func updateUIForNewState(
        _ state: State?,
        animated: Bool,
        completion: @escaping UpdateUICompletion
    ) {
        let oldContextView = contextView
        let newContextView = createContext(for: state)
        let transition = {
            [unowned self] in
            self.removeContext(oldContextView)
            self.addContext(newContextView)
        }
        let transitionCompletion: (Bool) -> Void = {
            [weak self] isCompleted in
            guard let self else { return }

            self.contextView = isCompleted ? newContextView : oldContextView
            completion(isCompleted)
        }

        if animated {
            UIView.transition(
                with: self,
                duration: 0.2,
                options: .transitionCrossDissolve,
                animations: transition,
                completion: transitionCompletion
            )
        } else {
            transition()
            transitionCompletion(true)
        }
    }

    private func addBackground(_ theme: WebNoContentViewTheme) {
        customizeAppearance(theme.background)
    }

    private func addContent(_ theme: WebNoContentViewTheme) {
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top == safeAreaInsets.top + theme.contentEdgeInsets.top
            $0.leading == safeAreaInsets.left + theme.contentEdgeInsets.leading
            $0.bottom == safeAreaInsets.bottom + theme.contentEdgeInsets.bottom
            $0.trailing == safeAreaInsets.right + theme.contentEdgeInsets.trailing
        }
    }

    private func addContext(_ view: UIView?) {
        guard let view else { return }

        contentView.addSubview(view)
        view.snp.makeConstraints {
            $0.top == safeAreaInsets.top
            $0.leading == safeAreaInsets.left
            $0.bottom == safeAreaInsets.bottom
            $0.trailing == safeAreaInsets.right
        }
    }

    private func removeContext(_ view: UIView?) {
        guard let view else { return }
        view.removeFromSuperview()
    }

    private func createContext(for state: State?) -> UIView? {
        switch state {
        case .none:
            return nil
        case .loading(let theme):
            return createLoading(theme)
        case .error(let theme, let viewModel):
            return createError(
                theme,
                viewModel
            )
        }
    }

    private func createLoading(_ theme: WebLoadingViewTheme) -> WebLoadingView {
        let view = WebLoadingView(theme)
        view.startAnimating()
        return view
    }

    private func createError(
        _ theme: DiscoverErrorViewTheme,
        _ viewModel: WebErrorViewModel
    ) -> DiscoverErrorView {
        let view = DiscoverErrorView(theme)
        view.bindData(viewModel)
        view.startObserving(event: .retry) {
            [unowned self] in
            let interaction = self.uiInteractions[.retry]
            interaction?.publish()
        }
        return view
    }
}

extension WebNoContentView {
    enum State: Equatable {
        case loading(WebLoadingViewTheme)
        case error(DiscoverErrorViewTheme, WebErrorViewModel)

        static func == (
            lhs: State,
            rhs: State
        ) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading):
                return true
            case (.error(_, let lhsViewModel), .error(_, let rhsViewModel)):
                return lhsViewModel == rhsViewModel
            default:
                return false
            }
        }
    }
}

extension WebNoContentView {
    enum Event {
        case retry
    }
}
