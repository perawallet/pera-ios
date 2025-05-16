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

//   CarouselBannerView.swift

import MacaroonUIKit
import MacaroonURLImage
import UIKit

final class CarouselBannerView:
    UIView,
    ViewComposable,
    ListReusable {
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var banners: [CustomCarouselBannerItemModel] = []

    func customize(_ theme: CarouselBannerViewTheme) {
        addBackground(theme)
        addCollectionView(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ items: [CustomCarouselBannerItemModel]) {
        self.banners = items
        collectionView.reloadData()
    }

    func prepareForReuse() {
    }
}

extension CarouselBannerView {
    private func addBackground(_ theme: CarouselBannerViewTheme) {
        customizeAppearance(theme.background)
    }
    
    private func addCollectionView(_ theme: CarouselBannerViewTheme) {

        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.flowLayout.scrollDirection = .horizontal
        collectionView.register(CarouselBannerItemCell.self)
        collectionView.backgroundColor = theme.background.backgroundColor?.uiColor
        collectionView.delegate = self
        collectionView.dataSource = self
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}

extension CarouselBannerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalHorizontalSpacing: CGFloat = 12 * 2 // 12pt peek on each side
        let itemWidth = collectionView.bounds.width - totalHorizontalSpacing

        return CGSize(width: itemWidth, height: 72)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}

extension CarouselBannerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return banners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(CarouselBannerItemCell.self, at: indexPath)
        cell.bindData(banners[indexPath.row])
        return cell
    }
}
