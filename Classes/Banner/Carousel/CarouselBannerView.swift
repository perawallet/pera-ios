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
    
    let textLabel = UILabel()

    func customize(_ theme: CarouselBannerViewTheme) {
        addBackground(theme)
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func bindData(_ items: [CustomCarouselBannerItemModel]) {
        textLabel.text = "Carousel Banner (\(items.count))"
    }

    func prepareForReuse() {
    }
}

extension CarouselBannerView {
    private func addBackground(_ theme: CarouselBannerViewTheme) {
        customizeAppearance(theme.background)
        
        addSubview(textLabel)
        textLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
}
