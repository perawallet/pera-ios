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
import UIKit


final class CarouselBannerView:
    UIView,
    ViewComposable,
    ListReusable {
    
    weak var delegate: CarouselBannerDelegate?
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let pageControl = CarouselPageControl()
    private(set) var banners: [CarouselBannerItemModel] = []

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
        pageControl.isHidden = items.count <= 1
        collectionView.reloadData()
    }

    func prepareForReuse() {
        banners.removeAll()
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
        collectionView.isPagingEnabled = false
        collectionView.clipsToBounds = false
        collectionView.collectionViewLayout = CarouselFlowLayout(spacing: theme.collectionViewSpacing, insets: theme.collectionViewInsets)
        collectionView.register(CarouselBannerItemCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.decelerationRate = .fast
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.collectionViewTopPadding)
            $0.leading.trailing.equalToSuperview()
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
        pageControl.addTarget(self, action: #selector(pageControlDidChange), for: .valueChanged)
    }
    
    @objc private func pageControlDidChange(_ sender: UIPageControl) {
        let indexPath = IndexPath(item: sender.currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

extension CarouselBannerView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didPressBanner(in: banners[indexPath.item])
    }
}

extension CarouselBannerView: UIScrollViewDelegate {
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let pageWidth = layout.itemSize.width + layout.minimumLineSpacing
        var targetX = targetContentOffset.pointee.x + scrollView.contentInset.left
        let page = round(targetX / pageWidth)
        targetX = page * pageWidth - scrollView.contentInset.left
        targetContentOffset.pointee.x = targetX
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let pageWidth = layout.itemSize.width + layout.minimumLineSpacing
        let offsetX = scrollView.contentOffset.x + scrollView.contentInset.left
        let page = Int(round(offsetX / pageWidth))

        pageControl.currentPage = max(0, min(page, pageControl.numberOfPages - 1))
    }
}

extension CarouselBannerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        banners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(CarouselBannerItemCell.self, at: indexPath)
        cell.bindData(banners[indexPath.item])
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
