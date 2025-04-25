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

//   SelectAssetListItemCell.swift

import UIKit

final class SelectAssetListItemCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let theme = SelectAssetListItemCellTheme()
    
    private let contextView: PrimaryListItemView = {
        let view = PrimaryListItemView()
        view.customize(SelectAssetListItemCell.theme.context)
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
            contextView.topAnchor.constraint(equalTo: topAnchor, constant: Self.theme.contextEdgeInsets.top),
            contextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Self.theme.contextEdgeInsets.leading),
            contextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Self.theme.contextEdgeInsets.trailing),
            contextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Self.theme.contextEdgeInsets.bottom),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 80.0),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24.0),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1.0)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Actions
    
    func bindData(_ viewModel: SelectAssetListItemViewModel) {
        contextView.bindData(viewModel)
    }
    
    // MARK: - Helpers
    
    static func calculatePreferredSize(
        _ viewModel: SelectAssetListItemViewModel?,
        for theme: SelectAssetListItemCellTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = size.width
        let contextWidth =
            width -
            theme.contextEdgeInsets.leading -
            theme.contextEdgeInsets.trailing
        let maxContextSize = CGSize(width: contextWidth, height: .greatestFiniteMagnitude)
        let contextSize = PrimaryListItemView.calculatePreferredSize(
            viewModel,
            for: theme.context,
            fittingIn: maxContextSize
        )
        let preferredHeight =
            theme.contextEdgeInsets.top +
            contextSize.height +
            theme.contextEdgeInsets.bottom
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }
}
