// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   ManageAssetsListItemLoadingView.swift

import MacaroonUIKit
import UIKit

final class ManageAssetsListItemLoadingView:
    View,
    ListReusable,
    ShimmerAnimationDisplaying {
    private lazy var imageView = ShimmerView()
    private lazy var textContainer = UIView()
    private lazy var titleView = ShimmerView()
    private lazy var subtitleView = ShimmerView()
    private lazy var actionView = ShimmerView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = false
        customize(ManageAssetsListItemLoadingViewTheme())
    }
    
    func customize(_ theme: ManageAssetsListItemLoadingViewTheme) {
        addImageView(theme)
        addTextContainer(theme)
        addActionView(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    class func calculatePreferredSize(
        for theme: ManageAssetsListItemLoadingViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        let width = size.width
        
        let imageHeight = theme.imageViewSize.h
        let textContainerHeight =
            theme.titleViewSize.h +
            theme.subtitleTopPadding +
            theme.subtitleViewSize.h
        let actionHeight = theme.actionViewSize.h
        
        let contentHeight = max(textContainerHeight.ceil(), actionHeight.ceil())
        let preferredHeight = max(imageHeight.ceil(), contentHeight)
        
        return CGSize((width, min(preferredHeight.ceil(), size.height)))
    }
}

extension ManageAssetsListItemLoadingView {
    private func addImageView(_ theme: ManageAssetsListItemLoadingViewTheme) {
        imageView.draw(corner: Corner(radius: theme.imageViewCorner))
        
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(
                CGSize(width: theme.imageViewSize.w,
                       height: theme.imageViewSize.h)
            )
        }
    }
    
    private func addTextContainer(_ theme: ManageAssetsListItemLoadingViewTheme) {
        addSubview(textContainer)
        textContainer.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.textContainerLeadingMargin)
            $0.centerY.equalToSuperview()
        }
        
        addTitleView(theme)
        addSubtitleView(theme)
    }
    
    private func addTitleView(_ theme: ManageAssetsListItemLoadingViewTheme) {
        titleView.draw(corner: Corner(radius: theme.titleViewCorner))

        textContainer.addSubview(titleView)
        titleView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.size.equalTo(
                CGSize(
                    width: theme.titleViewSize.w,
                    height: theme.titleViewSize.h
                )
            )
        }
    }
    
    private func addSubtitleView(_ theme: ManageAssetsListItemLoadingViewTheme) {
        subtitleView.draw(corner: Corner(radius: theme.subtitleViewCorner))

        textContainer.addSubview(subtitleView)
        subtitleView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(theme.subtitleTopPadding)
            $0.leading.bottom.equalToSuperview()
            $0.size.equalTo(
                CGSize(
                    width: theme.subtitleViewSize.w,
                    height: theme.subtitleViewSize.h
                )
            )
        }
    }
    
    private func addActionView(_ theme: ManageAssetsListItemLoadingViewTheme) {
        actionView.draw(corner: Corner(radius: theme.actionViewCorner))

        addSubview(actionView)
        actionView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(
                CGSize(width: theme.actionViewSize.w,
                       height: theme.actionViewSize.h)
            )
        }
    }
}
