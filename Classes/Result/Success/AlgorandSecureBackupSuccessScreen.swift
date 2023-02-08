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

//   AlgorandSecureBackupSuccessScreen.swift

import Foundation
import UIKit
import MacaroonUIKit

final class AlgorandSecureBackupSuccessScreen: ScrollScreen  {
    typealias EventHandler = (Event, AlgorandSecureBackupSuccessScreen) -> Void

    var eventHandler: EventHandler?

    private lazy var contextView = UIView()
    private lazy var headerView = ResultView()
    private lazy var fileContentView = TripleShadowView()
    private lazy var fileIconView = UIImageView()
    private lazy var fileInfoContentView = UIView()
    private lazy var fileInfoNameView = UILabel()
    private lazy var fileInfoSizeView = UILabel()
    private lazy var fileCopyAccessory = UIButton()
    private lazy var saveActionView = MacaroonUIKit.Button(theme.saveActionLayout)
    private lazy var doneActionView = MacaroonUIKit.Button()

    private let theme: AlgorandSecureBackupSuccessScreenTheme

    init(theme: AlgorandSecureBackupSuccessScreenTheme = .init()) {
        self.theme = theme
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
    }

    override func addFooter() {
        super.addFooter()

        var backgroundGradient = Gradient()
        backgroundGradient.colors = [
            Colors.Defaults.background.uiColor.withAlphaComponent(0),
            Colors.Defaults.background.uiColor
        ]
        backgroundGradient.locations = [ 0, 0.2, 1 ]
        footerBackgroundEffect = LinearGradientEffect(gradient: backgroundGradient)
    }

    private func addUI() {
        addBackground()
        addContext()
        addSaveAction()
        addDoneAction()
    }
}

extension AlgorandSecureBackupSuccessScreen {
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

        addHeader()
        addFileContent()
    }

    private func addHeader() {
        headerView.customize(theme.header)

        contextView.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        bindHeader()

        headerView.startObserving(event: .performHyperlinkAction) {
            [unowned self] in
            self.open(AlgorandWeb.algorandSecureBackup.link)
        }
    }

    private func addFileContent() {
        fileContentView.drawAppearance(shadow: theme.fileContentFirstShadow)
        fileContentView.drawAppearance(secondShadow: theme.fileContentSecondShadow)
        fileContentView.drawAppearance(thirdShadow: theme.fileContentThirdShadow)

        contextView.addSubview(fileContentView)
        fileContentView.snp.makeConstraints {
            $0.top == headerView.snp.bottom + theme.spacingBetweenHeaderAndFileContent
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        addFileIcon()
        addFileInfoContent()
        addFileCopyAccessory()
    }

    private func addFileIcon() {
        fileIconView.customizeAppearance(theme.fileIcon)

        fileContentView.addSubview(fileIconView)
        fileIconView.fitToIntrinsicSize()
        fileIconView.snp.makeConstraints {
            $0.top == theme.fileContentPaddings.top
            $0.leading == theme.fileContentPaddings.leading
            $0.bottom == theme.fileContentPaddings.bottom
        }
    }

    private func addFileInfoContent() {
        fileContentView.addSubview(fileInfoContentView)
        fileInfoContentView.snp.makeConstraints {
            $0.top >= 0
            $0.leading == fileIconView.snp.trailing + theme.spacingBetweenFileIconAndFileInfoContent
            $0.bottom <= 0
            $0.centerY == 0
        }

        addFileInfoName()
        addFileInfoSize()
    }

    private func addFileInfoName() {
        fileInfoNameView.customizeAppearance(theme.fileInfoName)

        fileInfoContentView.addSubview(fileInfoNameView)
        fileInfoNameView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }

        bindFileInfoName()
    }

    private func addFileInfoSize() {
        fileInfoSizeView.customizeAppearance(theme.fileInfoSize)

        fileInfoContentView.addSubview(fileInfoSizeView)
        fileInfoSizeView.snp.makeConstraints {
            $0.top == fileInfoNameView.snp.bottom + theme.spacingBetweenFileInfoNameAndFileInfoSize
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        bindFileInfoSize()
    }

    private func addFileCopyAccessory() {
        fileCopyAccessory.customizeAppearance(theme.fileCopyAccessory)

        fileContentView.addSubview(fileCopyAccessory)
        fileCopyAccessory.fitToIntrinsicSize()
        fileCopyAccessory.snp.makeConstraints {
            $0.leading == fileInfoContentView.snp.trailing + theme.spacingBetweenFileInfoContentAndFileCopyAccessory
            $0.trailing == theme.fileContentPaddings.trailing
            $0.centerY == 0
        }

        fileCopyAccessory.addTouch(
            target: self,
            action: #selector(performCopy)
        )
    }

    private func addSaveAction() {
        saveActionView.customizeAppearance(theme.saveAction)

        footerView.addSubview(saveActionView)
        saveActionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)
        saveActionView.snp.makeConstraints {
            $0.top == theme.actionMargins.top
            $0.leading == theme.actionMargins.leading
            $0.trailing == theme.actionMargins.trailing
        }

        saveActionView.addTouch(
            target: self,
            action: #selector(performSave)
        )
    }

    private func addDoneAction() {
        doneActionView.customizeAppearance(theme.doneAction)

        footerView.addSubview(doneActionView)
        doneActionView.contentEdgeInsets = UIEdgeInsets(theme.actionEdgeInsets)
        doneActionView.snp.makeConstraints {
            $0.top == saveActionView.snp.bottom + theme.spacingBetweenActions
            $0.leading == theme.actionMargins.leading
            $0.bottom == theme.actionMargins.bottom
            $0.trailing == theme.actionMargins.trailing
        }

        doneActionView.addTouch(
            target: self,
            action: #selector(performDone)
        )
    }
}

extension AlgorandSecureBackupSuccessScreen {
    private func bindHeader() {
        let viewModel = AlgorandSecureBackupSuccessHeaderViewModel()
        headerView.bindData(viewModel)
    }

    private func bindFileInfoName() {
        fileInfoNameView.attributedText = "19/01/2023_backup.txt".footnoteMedium(lineBreakMode: .byTruncatingTail)
    }

    private func bindFileInfoSize() {
        fileInfoSizeView.attributedText = "239 KB".footnoteRegular(lineBreakMode: .byTruncatingTail)
    }
}

extension AlgorandSecureBackupSuccessScreen {
    @objc
    private func performCopy() {}

    @objc
    private func performSave() {
        eventHandler?(.performSave, self)
    }

    @objc
    private func performDone() {
        eventHandler?(.performDone, self)
    }
}

extension AlgorandSecureBackupSuccessScreen {
    enum Event {
        case performSave
        case performDone
    }
}
