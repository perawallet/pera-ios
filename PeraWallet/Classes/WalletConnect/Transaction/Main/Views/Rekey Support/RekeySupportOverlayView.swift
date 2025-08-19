// Copyright 2022-2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   RekeySupportOverlayView.swift

import UIKit

final class RekeySupportOverlayView: UIView {
    
    enum Variant {
        case accessBlocked
        case warning
    }
    
    // MARK: - Subviews
    
    private let iconView: UIImageView = {
        let view = UIImageView()
        view.image = .iconInfoRed.template
        view.tintColor = .Helpers.negative
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .Text.main
        view.textAlignment = .center
        view.font = Fonts.DMSans.regular.make(19.0).uiFont
        return view
    }()
    
    private let descriptionLabel: UILabel = {
        let view = UILabel()
        view.textColor = .Text.gray
        view.textAlignment = .center
        view.font = Fonts.DMSans.regular.make(15.0).uiFont
        view.numberOfLines = 0
        return view
    }()
    
    private let primaryButton: Button = {
        let view = Button()
        view.customize(ButtonPrimaryTheme())
        return view
    }()
    
    private let secondaryButton: Button = {
        let view = Button()
        view.customize(ButtonSecondaryTheme())
        return view
    }()
    
    // MARK: - Properties
    
    var onPrimaryButtonTap: (() -> Void)?
    var onSecondaryButtonTap: (() -> Void)?
    
    // MARK: - Initialisers
    
    init(variant: Variant) {
        super.init(frame: .zero)
        setupView(variant: variant)
        setupSubviews()
        setupCallbacks()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setups
    
    private func setupView(variant: Variant) {
        backgroundColor = .Defaults.bg
        titleLabel.text = variant.title
        descriptionLabel.text = variant.description
        primaryButton.setTitle(variant.primaryButtonTitle, for: .normal)
        secondaryButton.setTitle(variant.secondaryButtonTitle, for: .normal)
    }
    
    private func setupSubviews() {
        
        [iconView, titleLabel, descriptionLabel, primaryButton, secondaryButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        let constraints = [
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 32.0),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 72.0),
            iconView.heightAnchor.constraint(equalToConstant: 72.0),
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 20.0),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25.0),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25.0),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.0),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25.0),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25.0),
            primaryButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32.0),
            primaryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25.0),
            primaryButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25.0),
            secondaryButton.topAnchor.constraint(equalTo: primaryButton.bottomAnchor, constant: 16.0),
            secondaryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25.0),
            secondaryButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25.0),
            secondaryButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12.0)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupCallbacks() {
        primaryButton.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(secondaryButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Handlers
    
    @objc private func primaryButtonTapped() {
        onPrimaryButtonTap?()
    }
    
    @objc private func secondaryButtonTapped() {
        onSecondaryButtonTap?()
    }
}

private extension RekeySupportOverlayView.Variant {
    
    var title: String {
        switch self {
        case .accessBlocked:
            return String(localized: "rekey-support-blocked-overlay-title")
        case .warning:
            return String(localized: "rekey-support-warning-overlay-title")
        }
    }
    
    var description: String {
        switch self {
        case .accessBlocked:
            return String(localized: "rekey-support-blocked-overlay-description")
        case .warning:
            return String(localized: "rekey-support-warning-overlay-description")
        }
    }
    
    var primaryButtonTitle: String {
        switch self {
        case .accessBlocked:
            return String(localized: "rekey-support-blocked-overlay-button-primary")
        case .warning:
            return String(localized: "rekey-support-warning-overlay-button-primary")
        }
    }
    
    var secondaryButtonTitle: String { String(localized: "common-not-now") }
}
