// Copyright 2024 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   RecoverAccountsLoadingScreen.swift

import MacaroonUIKit
import UIKit

final class RecoverAccountsLoadingScreen: BaseViewController {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?

    private let viewModel = RecoverAccountsLoadingViewModel()
    private lazy var theme = Theme()
    private lazy var stackView = VStackView()
    private lazy var imageBackgroundView = UIView()
    private lazy var leftImageView = UIImageView()
    private lazy var rightImageView = UIImageView()
    private lazy var imageView = LottieImageView()
    private lazy var titleView = UILabel()

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()
        hidesCloseBarButtonItem = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        eventHandler?(.willStartLoading)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        eventHandler?(.didStartLoading)
        setPopGestureEnabled(false)
        playAnimation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        eventHandler?(.didStopLoading)
        setPopGestureEnabled(true)
    }

    override func configureAppearance() {
        super.configureAppearance()
        view.customizeAppearance(theme.background)
    }

    override func prepareLayout() {
        super.prepareLayout()
        addStackView()
    }

    override func bindData() {
        super.bindData()

        if let image = getAnimationName() {
            imageView.setAnimation(image)
        }
        leftImageView.customizeAppearance(theme.leftImage)
        rightImageView.customizeAppearance(theme.rightImage)
        if let title = viewModel.title {
            title.load(in: titleView)
        } else {
            titleView.text = nil
        }
    }

    override func didTapBackBarButton() -> Bool {
        return false
    }
    
    override func preferredUserInterfaceStyleDidChange(to userInterfaceStyle: UIUserInterfaceStyle) {
        super.preferredUserInterfaceStyleDidChange(to: userInterfaceStyle)
        if let image = getAnimationName() {
            imageView.setAnimation(image)
            playAnimation()
        }
    }
    
    private func getAnimationName() -> String? {
        let suffix: String = "dots"
        let root: String
        switch traitCollection.userInterfaceStyle {
        case .dark: root = "dark"
        default: root = "light"
        }
        return root + "-" + suffix
    }
    
    private func playAnimation() {
        imageView.play(with: LottieImageView.Configuration())
    }
}

extension RecoverAccountsLoadingScreen {
    
    private func addStackView() {
        view.addSubview(stackView)
        stackView.spacing = theme.spacingBetweenImageAndTitle
        stackView.snp.makeConstraints {
            $0.leading == theme.titleHorizontalInset
            $0.trailing == theme.titleHorizontalInset
            $0.center.equalToSuperview()
        }
        addImageBackground()
        addTitle()
    }

    private func addImageBackground() {
        imageBackgroundView.customizeAppearance(theme.imageBackground)
        imageBackgroundView.layer.draw(corner: theme.imageBackgroundCorner)

        view.addSubview(imageBackgroundView)
        imageBackgroundView.fitToIntrinsicSize()
        stackView.addArrangedSubview(imageBackgroundView)
        addImages()
    }

    private func addImages() {
        imageBackgroundView.addSubview(imageView)
        imageView.fitToIntrinsicSize()
        imageView.snp.makeConstraints {
            $0.center == 0
            $0.fitToSize(theme.imageSize)
        }
        
        imageBackgroundView.addSubview(leftImageView)
        leftImageView.snp.makeConstraints {
            $0.trailing.equalTo(imageView.snp.leading).offset(-theme.horizontalPadding)
            $0.leading.equalToSuperview()
            $0.fitToSize(theme.leftImageSize)
            $0.top.bottom.equalToSuperview()
        }
        
        imageBackgroundView.addSubview(rightImageView)
        rightImageView.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(theme.horizontalPadding)
            $0.trailing.equalToSuperview()
            $0.fitToSize(theme.rightImageSize)
            $0.top.bottom.equalToSuperview()
        }
    }
    
    private func addTitle() {
        titleView.customizeAppearance(theme.title)
        titleView.fitToIntrinsicSize()
        stackView.addArrangedSubview(titleView)
    }
}

extension RecoverAccountsLoadingScreen {
    private func setPopGestureEnabled(_ isEnabled: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = isEnabled
    }
}

extension RecoverAccountsLoadingScreen {
    enum Event {
        case willStartLoading
        case didStartLoading
        case didStopLoading
    }
}
