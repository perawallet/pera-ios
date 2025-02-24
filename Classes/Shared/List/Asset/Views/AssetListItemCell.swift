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

//   AssetListItemCell.swift

import UIKit

final class AssetListItemCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let theme = AssetListItemTheme()
    
    private let contextView: PrimaryListItemView = {
        let view = PrimaryListItemView()
        view.customize(AssetListItemCell.theme)
        return view
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.Layer.grayLighter.uiColor
        return view
    }()
    
    // MARK: - Initialisers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setups
    
    private func setupConstraints() {
        
        [contextView, separatorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        let constraints = [
            contextView.topAnchor.constraint(equalTo: topAnchor, constant: Self.theme.verticalPadding),
            contextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Self.theme.horizontalPadding),
            contextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Self.theme.horizontalPadding),
            contextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Self.theme.verticalPadding),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 80.0),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24.0),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1.0)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Actions
    
    func bindData(_ data: any PrimaryListItemViewModel) {
        contextView.bindData(data)
    }
    
    // MARK: - Helpers
    
    static func calculatePreferredSize(_ viewModel: PrimaryListItemViewModel?, for theme: PrimaryListItemViewTheme, fittingIn size: CGSize) -> CGSize {
        var preferredSize = PrimaryListItemView.calculatePreferredSize(viewModel, for: theme, fittingIn: size)
        preferredSize.height += self.theme.verticalPadding * 2.0
        return preferredSize
    }
}
