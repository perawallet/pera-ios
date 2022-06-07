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

//   CopyAddressStoryScreen.swift

import Foundation
import MacaroonStorySheet
import MacaroonUIKit
import UIKit

final class CopyAddressStoryScreen:
    BaseScrollViewController,
    StorySheetPresentable {
    typealias EventHandler = (Event) -> Void
    
    var eventHandler: EventHandler?

    private lazy var imageView = ImageView()
    private lazy var titleLabel = Label()
    private lazy var descriptionLabel = Label()
    
    private lazy var closeActionView =
        ViewFactory.Button.makeSecondaryButton(theme.closeButtonTitle)

    private let theme: CopyAddressStoryScreenTheme
    
    init(
        configuration: ViewControllerConfiguration,
        theme: CopyAddressStoryScreenTheme = .init()
    ) {
        self.theme = theme

        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }
    
    private func build() {
        addBackground()
        addImage()
        addTitle()
        addDescription()
        addCloseAction()
    }
}

extension CopyAddressStoryScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }
    
    private func addImage() {
        imageView.customizeAppearance(theme.image)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top == theme.imageTopInset
            make.centerX == theme.imageCenterXInset
        }
    }
    
    private func addTitle() {
        titleLabel.customizeAppearance(theme.title)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top == imageView.snp.bottom + theme.titleTopInset
            make.leading == theme.defaultInset
            make.trailing == theme.defaultInset
        }
    }
    
    private func addDescription() {
        descriptionLabel.customizeAppearance(theme.description)
        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top == titleLabel.snp.bottom + theme.descriptionVerticalMargins.top
            make.leading == theme.defaultInset
            make.trailing == theme.defaultInset
            make.bottom == theme.descriptionVerticalMargins.bottom
        }
    }
    
    private func addCloseAction() {
        view.addSubview(closeActionView)
        closeActionView.snp.makeConstraints {
            $0.leading == theme.defaultInset
            $0.bottom == theme.closeButtonBottomInset
            $0.trailing == theme.defaultInset
            $0.height.equalTo(theme.closeButtonHeight)
        }
        
        closeActionView.addTouch(
            target: self,
            action: #selector(close)
        )
    }
}

extension CopyAddressStoryScreen {
    @objc
    private func close() {
        eventHandler?(.close)
    }
}

extension CopyAddressStoryScreen {
    enum Event {
        case close
    }
}
