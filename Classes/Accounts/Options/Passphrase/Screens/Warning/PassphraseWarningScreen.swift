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

//   PassphraseWarningScreen.swift

import Foundation
import UIKit
import MacaroonUIKit
import MacaroonBottomSheet

final class PassphraseWarningScreen:
    BaseScrollViewController,
    BottomSheetScrollPresentable {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var contextView = UIView()
    private lazy var iconImageView = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    private lazy var mainButton = Button()
    private lazy var secondaryButton = Button()

    private let theme: PassphraseWarningScreenTheme

    init(
        theme: PassphraseWarningScreenTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.theme = theme
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
    }

    private func addUI() {
        addBackground()
        addContext()
    }
}

extension PassphraseWarningScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addContext() {
        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.top == theme.contextPaddings.top
            $0.leading == theme.contextPaddings.leading
            $0.bottom == theme.contextPaddings.bottom
            $0.trailing == theme.contextPaddings.trailing
        }

        addIcon()
        addTitle()
        addDescription()
        addButtons()
    }
}

extension PassphraseWarningScreen {
    
    private func addIcon() {
        iconImageView.customizeAppearance(theme.icon)
        contextView.addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints {
            $0.top == 0
            $0.centerX.equalToSuperview()
        }
    }

    private func addTitle() {
        titleLabel.customizeAppearance(theme.title)
        contextView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.top == iconImageView.snp.bottom + theme.spacingBetweenIconAndTitle
            $0.centerX.equalToSuperview()
        }
    }
    
    private func addDescription() {
        descriptionLabel.customizeAppearance(theme.description)
        contextView.addSubview(descriptionLabel)

        descriptionLabel.snp.makeConstraints {
            $0.top == titleLabel.snp.bottom + theme.spacingBetweenTitleAndDescription
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.leading.equalToSuperview()
        }
    }
    
    private func addButtons() {
        mainButton.customize(theme.mainButtonTheme)
        mainButton.bindData(ButtonCommonViewModel(title: String(localized: "title-reveal-passphrase")))
        mainButton.addTarget(self, action: #selector(mainButtonTapped), for: .touchUpInside)
        contextView.addSubview(mainButton)
        
        secondaryButton.customize(theme.secondaryButtonTheme)
        secondaryButton.bindData(ButtonCommonViewModel(title: String(localized: "title-close")))
        secondaryButton.addTarget(self, action: #selector(secondaryButtonTapped), for: .touchUpInside)
        contextView.addSubview(secondaryButton)
        
        mainButton.snp.makeConstraints {
            $0.top == descriptionLabel.snp.bottom + theme.spacingBetweendDescriptionAndMainButton
            $0.leading.equalToSuperview().inset(4)
            $0.trailing.equalToSuperview().inset(4)
            $0.height.equalTo(theme.buttonHeight)
        }
        
        secondaryButton.snp.makeConstraints {
            $0.top == mainButton.snp.bottom + theme.spacingBetweendMainAndSecondaryButtons
            $0.leading.equalToSuperview().inset(4)
            $0.trailing.equalToSuperview().inset(4)
            $0.height.equalTo(theme.buttonHeight)
            $0.bottom.equalToSuperview().inset(theme.secondaryButtonBottomPadding)
        }
    }
    
    @objc private func mainButtonTapped() {
        eventHandler?(.reveal)
    }
    
    @objc private func secondaryButtonTapped() {
        eventHandler?(.close)
    }
}

 extension PassphraseWarningScreen {
     enum Event {
         case reveal
         case close
     }
 }
