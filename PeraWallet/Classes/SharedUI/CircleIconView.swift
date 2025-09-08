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

//   CircleIconView.swift

import UIKit

final class CircleIconView: UIView {
    
    // MARK: - Subviews
    
    private let iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    
    @MainActor
    var image: UIImage? {
        get { iconView.image }
        set { iconView.image = newValue }
    }
    
    @MainActor
    var padding: CGFloat = 0.0 {
        didSet { updateConstraints(padding: padding) }
    }
    
    // MARK: - Initialisers
    
    init() {
        super.init(frame: .zero)
        setupViews()
        updateConstraints(padding: padding)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setups
    
    private func setupViews() {
        addSubview(iconView)
    }
    
    private func updateConstraints(padding: CGFloat) {
        
        let oldConstraints = constraints.filter { $0.firstItem === self.iconView }
        NSLayoutConstraint.deactivate(oldConstraints)
        
        let constraints = [
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            iconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            iconView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        layoutIfNeeded()
    }
    
    // MARK: - Updates
    
    private func updateCorners() {
        layer.cornerRadius = min(bounds.width, bounds.height) / 2.0
    }
    
    // MARK: - Autolayout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCorners()
    }
}
