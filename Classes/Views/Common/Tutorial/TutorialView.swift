// Copyright 2019 Algorand, Inc.

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
//  TutorialView.swift

import UIKit
import Macaroon

final class TutorialView: View {
    weak var delegate: TutorialViewDelegate?

    private lazy var imageView = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    private lazy var warningImage = UIImageView()
    private lazy var warningLabel = UILabel()
    private lazy var mainButton = Button()
    private lazy var actionButton = Button()

    func customize(_ theme: TutorialViewTheme, isActionable: Bool) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addImageView(theme)
        addTitleLabel(theme)
        addDescriptionLabel(theme)
        addMainButton(theme, isActionable: isActionable)
        addWarningLabel(theme)
        addWarningImage(theme)
        
        if isActionable {
            addActionButton(theme)
        }
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func setListeners() {
        mainButton.addTarget(self, action: #selector(notifyDelegateToTutorialApprovaed), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(notifyDelegateToTakeAction), for: .touchUpInside)
    }
}

extension TutorialView {
    private func addImageView(_ theme: TutorialViewTheme) {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(theme.imagePaddings.leading)
            $0.top.equalToSuperview().inset(theme.imagePaddings.top)
        }
    }

    private func addTitleLabel(_ theme: TutorialViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(imageView.snp.bottom).offset(theme.titleTopInset)
        }
    }

    private func addDescriptionLabel(_ theme: TutorialViewTheme) {
        descriptionLabel.customizeAppearance(theme.description)

        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.descriptionHorizontalInset)
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.descriptionTopInset)
        }
    }

    private func addWarningLabel(_ theme: TutorialViewTheme) {
        warningLabel.customizeAppearance(theme.warningTitle)
        addSubview(warningLabel)

        warningLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(theme.warningTitlePaddings.leading)
            $0.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.bottom.equalTo(mainButton.snp.top).offset(-theme.warningTitlePaddings.bottom)
        }
    }

    private func addWarningImage(_ theme: TutorialViewTheme) {
        warningImage.customizeAppearance(theme.warningImage)
        addSubview(warningImage)

        warningImage.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(theme.horizontalInset)
            $0.top.equalTo(warningLabel.snp.top)
        }
    }

    private func addMainButton(_ theme: TutorialViewTheme, isActionable: Bool) {
        mainButton.customize(theme.mainButtonTheme)

        addSubview(mainButton)
        mainButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.greaterThanOrEqualTo(descriptionLabel.snp.bottom).offset(theme.buttonInset)

            if !isActionable {
                $0.bottom.equalToSuperview().inset(theme.bottomInset + safeAreaBottom)
            }
        }
    }

    private func addActionButton(_ theme: TutorialViewTheme) {
        actionButton.customize(theme.actionButtonTheme)

        addSubview(actionButton)
        actionButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalTo(mainButton.snp.bottom).offset(theme.buttonInset)
            $0.bottom.equalToSuperview().inset(theme.bottomInset + safeAreaBottom)
        }
    }
}

extension TutorialView: ViewModelBindable {
    func bindData(_ viewModel: TutorialViewModel?) {
        titleLabel.text = viewModel?.title
        descriptionLabel.text = viewModel?.description
        imageView.image = viewModel?.image
        mainButton.bindData(ButtonCommonViewModel(title: viewModel?.mainButtonTitle))
        actionButton.bindData(ButtonCommonViewModel(title: viewModel?.actionTitle))
        
        if let warningDescription = viewModel?.warningDescription {
            warningLabel.text = warningDescription
        } else {
            warningLabel.isHidden = true
            warningImage.isHidden = true
        }
    }
}

extension TutorialView {
    @objc
    private func notifyDelegateToTutorialApprovaed() {
        delegate?.tutorialViewDidApproveTutorial(self)
    }

    @objc
    private func notifyDelegateToTakeAction() {
        delegate?.tutorialViewDidTakeAction(self)
    }
}

protocol TutorialViewDelegate: AnyObject {
    func tutorialViewDidApproveTutorial(_ tutorialView: TutorialView)
    func tutorialViewDidTakeAction(_ tutorialView: TutorialView)
}
