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

//   CarouselPageControl.swift

import UIKit

final class CarouselPageControl: UIPageControl {
    
    private lazy var activeImage = makeDot(width: 12, height: 4)
    private lazy var inactiveImage = makeDot(width: 4, height: 4)
    
    override var currentPage: Int {
        didSet { updateDots() }
    }
    
    override var numberOfPages: Int {
        didSet {
            preferredIndicatorImage = inactiveImage
            updateDots()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        customizeAppearance()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customizeAppearance()
    }
    
    private func customizeAppearance() {
        currentPageIndicatorTintColor = Colors.Text.main.uiColor
        pageIndicatorTintColor = Colors.Layer.gray.uiColor
        preferredIndicatorImage = inactiveImage
    }
    
    private func updateDots() {
        for i in 0..<numberOfPages {
            let image = i == currentPage ? activeImage : inactiveImage
            setIndicatorImage(image, forPage: i)
        }
    }
    
    private func makeDot(width: CGFloat, height: CGFloat) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: height / 2)
        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}
