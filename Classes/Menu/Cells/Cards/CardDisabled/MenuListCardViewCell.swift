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

//   MenuListCardViewCell.swift

import UIKit

protocol MenuListCardViewCellDelegate: AnyObject {
    func didPressActionButton(in cell: MenuListCardViewCell)
}

final class MenuListCardViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let theme = MenuListCardViewTheme()
    weak var delegate: MenuListCardViewCellDelegate?
    
    // MARK: - Subviews
    
    let contextView: MenuListCardView = {
        let view = MenuListCardView()
        view.customize(MenuListCardViewCell.theme)
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
    
    private func setupConstraints() {
        addSubview(contextView)
        
        contextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bindData(_ data: MenuOption) {
        contextView.bindData(data)
        contextView.delegate = self
    }
    
}

extension MenuListCardViewCell: MenuListCardViewDelegate {
    func didPressActionButton(in view: MenuListCardView) {
        delegate?.didPressActionButton(in: self)
    }
}
