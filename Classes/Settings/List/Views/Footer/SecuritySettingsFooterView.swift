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

//   SecuritySettingsFooterView.swift

import UIKit

final class SecuritySettingsFooterView: UICollectionReusableView {
    
    // MARK: - Subviews
    
    private let label: UILabel = {
        let view = UILabel()
        view.font = SecuritySettingsFooterView.usedFont
        view.textColor = .Text.gray
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    
    static let usedFont = Fonts.DMSans.regular.make(13.0).uiFont
    
    var title: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    // MARK: - Initialisers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setups
    
    private func setupViews() {
        
        addSubview(label)
        
        let constraints = [
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24.0),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24.0),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
