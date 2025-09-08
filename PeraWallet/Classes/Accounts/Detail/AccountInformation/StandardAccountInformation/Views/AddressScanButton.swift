// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AddressScanButton.swift

import UIKit

final class AddressScanButton: UIButton {
    
    // MARK: - Subviews
    
    private let iconView: UIImageView = {
        let view = UIImageView()
        view.image = .Wallet.scan
        view.tintColor = .ButtonSquare.icon
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let label: UILabel = {
        let view = UILabel()
        view.text = String(localized: "address-scan-button-title")
        view.textColor = .ButtonSquare.icon
        view.font = Fonts.DMSans.medium.make(13.0).uiFont
        return view
    }()
    
    // MARK: - Properties
    
    var onTap: (() -> Void)?
    
    // MARK: - Initialisers
    
    init() {
        super.init(frame: .zero)
        setupConstraints()
        setupViews()
        setupCallbacks()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setups
    
    private func setupConstraints() {
        
        [iconView, label].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        let constraints = [
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 12.0),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.0),
            iconView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12.0),
            iconView.widthAnchor.constraint(equalToConstant: 16.0),
            iconView.heightAnchor.constraint(equalToConstant: 16.0),
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8.0),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
            label.centerYAnchor.constraint(equalTo: iconView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupViews() {
        backgroundColor = .ButtonSquare.bg
        layer.cornerRadius = 8.0
    }
    
    private func setupCallbacks() {
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    // MARK: - Handlers
    
    @objc private func handleTap() {
        onTap?()
    }
}
