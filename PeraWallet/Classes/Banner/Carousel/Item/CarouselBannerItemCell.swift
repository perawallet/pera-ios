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

//   CarouselBannerItemCell.swift

import UIKit

final class CarouselBannerItemCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let theme = CarouselBannerItemViewTheme()
    weak var delegate: CarouselBannerDelegate? {
        didSet {
            contextView.delegate = delegate
        }
    }
    
    // MARK: - Subviews
    
    let contextView: CarouselBannerItemView = {
        let view = CarouselBannerItemView()
        view.customize(CarouselBannerItemCell.theme)
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
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
    }
    
    func bindData(_ data: CarouselBannerItemModel) {
        contextView.bindData(data)
    }
    
}
