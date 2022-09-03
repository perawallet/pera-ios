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

//
//  BaseScrollViewController.swift

import Foundation
import MacaroonBottomSheet
import MacaroonStorySheet
import MacaroonUIKit
import UIKit

class BaseScrollViewController: BaseViewController {
    var footerViewEffectStyle: ScrollScreenFooterView.EffectStyle = .none {
        willSet {
            footerBackgroundView.effectStyle = newValue
        }
    }

    private(set) lazy var scrollView: UIScrollView = {
        let scrollView = TouchDetectingScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private(set) lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .clear
        return contentView
    }()

    private(set) lazy var footerView: UIView = .init()
    private(set) lazy var footerBackgroundView = ScrollScreenFooterView()
    
    override func configureAppearance() {
        super.configureAppearance()
        view.backgroundColor = .clear
        contentView.backgroundColor = .clear
        scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        addScroll()
        addFooter()
    }

    private func addScroll() {
        view.addSubview(
            scrollView
        )
        scrollView.snp.makeConstraints {
            $0.setPaddings(
                (0, 0, 0, 0)
            )
        }

        addContent()
    }

    private func addContent() {
        scrollView.addSubview(
            contentView
        )
        contentView.snp.makeConstraints {
            $0.width == view

            $0.setPaddings(
                (0, 0, 0, 0)
            )
        }
    }

    private func addFooter() {
        view.addSubview(
            footerBackgroundView
        )
        footerBackgroundView.snp.makeConstraints {
            $0.setPaddings(
                (.noMetric, 0, 0, 0)
            )
        }

        footerBackgroundView.addSubview(
            footerView
        )
        footerView.snp.makeConstraints {
            $0.setPaddings(
                (0, 0, .noMetric, 0)
            )
            $0.setBottomPadding(
                0,
                inSafeAreaOf: footerBackgroundView
            )
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if contentView.bounds.isEmpty {
            return
        }

        updateScrollLayoutWhenViewDidLayoutSubviews()
        updateLayoutOnScroll()
    }

    private func updateLayoutOnScroll() {
        if footerView.bounds.isEmpty {
            return
        }

        footerBackgroundView.addBlur()
        footerBackgroundView.addGradient()

        let endOfContent = contentView.frame.maxY - scrollView.contentOffset.y
        let isFooterBackgroundViewHidden = endOfContent <= footerBackgroundView.frame.minY
        footerBackgroundView.setBlurVisible(!isFooterBackgroundViewHidden)
        footerBackgroundView.setGradientVisible(!isFooterBackgroundViewHidden)
    }

    private func updateScrollLayoutWhenViewDidLayoutSubviews() {
        if footerView.bounds.isEmpty {
            return
        }

        scrollView.setContentInset(
            bottom: footerView.bounds.height
        )
    }
}

extension BaseScrollViewController {
    private func setupScrollViewLayout() {
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func setupContentViewLayout() {
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.leading.trailing.equalTo(view)
            make.height.equalToSuperview().priority(.low)
        }
    }
}

extension BottomSheetScrollPresentable where Self: BaseScrollViewController {
    var modalHeight: ModalHeight {
        return .compressed
    }

    func calculateContentAreaHeightFitting(_ targetSize: CGSize) -> CGFloat {
        let contentSize = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )
        return contentSize.height
    }
}
