// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   Button.swift

import UIKit
import Macaroon

final class Button: UIButton {
    private lazy var indicatorView = ViewLoadingIndicator()

    func customize(_ theme: ButtonTheme) {
        customizeView(theme)
        customizeBackground(theme)
        customizeLabel(theme)

        addIndicator(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func bindData(_ viewModel: ButtonViewModel?) {
        bindTitle(viewModel)
        bindIcon(viewModel)
    }
}

extension Button {
    private func customizeView(_ theme: ButtonTheme) {
        layer.draw(corner: theme.corner)
        layer.masksToBounds = true
    }

    private func customizeBackground(_ theme: ButtonTheme) {
        setBackgroundColor(theme.backgroundColorSet.color, for: .normal)
        setBackgroundColor(theme.backgroundColorSet.disabled, for: .disabled)
    }

    private func customizeLabel(_ theme: ButtonTheme) {
        titleLabel?.customizeAppearance(theme.label)
        setTitleColor(theme.titleColorSet.color, for: .normal)
        setTitleColor(theme.titleColorSet.disabled, for: .disabled)

        titleEdgeInsets = UIEdgeInsets(theme.titleEdgeInsets)

        imageView?.customizeAppearance(theme.icon)
    }

    private func addIndicator(_ theme: ButtonTheme) {
        indicatorView.applyStyle(theme.indicator)

        addSubview(indicatorView)
        indicatorView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        indicatorView.isHidden = true
    }
}

extension Button {
    private func bindTitle(_ viewModel: ButtonViewModel?) {
        setTitle(viewModel?.title?.string, for: .normal)
    }

    private func bindIcon(_ viewModel: ButtonViewModel?) {
        guard viewModel?.iconSet != nil else {
            titleEdgeInsets = .zero
            return
        }

        setImage(viewModel?.iconSet?.image, for: .normal)
        setImage(viewModel?.iconSet?.disabled, for: .disabled)
    }
}

extension Button {
    func startLoading() {
        guard !indicatorView.isAnimating else { return }

        indicatorView.isHidden = false
        isEnabled = false
        titleLabel?.layer.opacity = .zero
        indicatorView.startAnimating()
    }

    func stopLoading() {
        guard indicatorView.isAnimating else { return }

        indicatorView.isHidden = true
        isEnabled = true
        titleLabel?.layer.opacity = 1
        indicatorView.stopAnimating()
    }
}

extension Button {
    private func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        guard let color = color else { return }

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
        let colorImage = renderer.image { _ in
            color.setFill()
            UIBezierPath(rect: CGRect(x: 0, y: 0, width: 1, height: 1)).fill()
        }
        setBackgroundImage(colorImage, for: state)
    }
}
