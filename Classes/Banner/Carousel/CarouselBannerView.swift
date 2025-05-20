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
    
    weak var delegate: CarouselBannerDelegate?
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let pageControl = CarouselPageControl()
    var banners: [CarouselBannerItemModel] = []

    func customize(_ theme: CarouselBannerViewTheme) {
        addBackground(theme)
        addCollectionView(theme)
        addPageControl(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ items: [CarouselBannerItemModel]) {
        banners = items
        pageControl.numberOfPages = items.count
        pageControl.currentPage = 0
        pageControl.isHidden = items.count == 1
        collectionView.reloadData()
    }

    func prepareForReuse() {
        banners.removeAll()
        collectionView.setContentOffset(.zero, animated: false)
        collectionView.reloadData()
        collectionView.delegate = nil
        collectionView.dataSource = nil
        pageControl.currentPage = 0
        pageControl.numberOfPages = 0
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
            $0.top.equalToSuperview().inset(theme.collectionViewTopPadding)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(theme.collectionViewHeight)
        }
    }
    
    private func addPageControl(_ theme: CarouselBannerViewTheme) {
        addSubview(pageControl)
        pageControl.snp.makeConstraints {
            $0.top == collectionView.snp.bottom
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
    }
}

extension CarouselBannerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalHorizontalSpacing: CGFloat = 12 * 2 // 12pt peek on each side
        let itemWidth = collectionView.bounds.width - totalHorizontalSpacing

        return CGSize(width: collectionView.bounds.width, height: 72)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let itemWidth = layout?.itemSize.width ?? 1
        let spacing = layout?.minimumLineSpacing ?? 0
        let pageWidth = collectionView.bounds.width
        let currentPage = Int((scrollView.contentOffset.x + (pageWidth / 2)) / pageWidth)
        pageControl.currentPage = currentPage

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didPressBanner(in: banners[indexPath.row])
    }
}

extension CarouselBannerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return banners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(CarouselBannerItemCell.self, at: indexPath)
        cell.bindData(banners[indexPath.row])
        cell.delegate = self
        return cell
    }
}

extension CarouselBannerView: CarouselBannerDelegate {
    func didPressBanner(in banner: CarouselBannerItemModel?) {
        delegate?.didPressBanner(in: banner)
    }
    
    func didTapCloseButton(in banner: CarouselBannerItemModel?) {
        delegate?.didTapCloseButton(in: banner)
    }
    
}
