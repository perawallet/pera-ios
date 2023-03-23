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

//   AlgorandSecureBackupImportBackupScreen.swift

import CoreServices
import Foundation
import MacaroonUIKit
import UIKit

final class AlgorandSecureBackupImportBackupScreen:
    BaseScrollViewController,
    NavigationBarLargeTitleConfigurable {
    typealias EventHandler = (Event, AlgorandSecureBackupImportBackupScreen) -> Void

    var eventHandler: EventHandler?

    var navigationBarScrollView: UIScrollView {
        return scrollView
    }

    var isNavigationBarAppeared: Bool {
        return isViewAppeared
    }

    private(set) lazy var navigationBarTitleView = createNavigationBarTitleView()
    private(set) lazy var navigationBarLargeTitleView = createNavigationBarLargeTitleView()
    private lazy var navigationBarLargeTitleController = NavigationBarLargeTitleController(screen: self)

    private lazy var headerView = UILabel()
    private lazy var uploadView = AlgorandSecureBackupImportFileView()
    private lazy var actionsView = VStackView()
    private lazy var pasteActionView = MacaroonUIKit.Button()
    private lazy var nextActionView = MacaroonUIKit.Button()

    private lazy var theme: AlgorandSecureBackupImportBackupScreenTheme = .init()

    private var isViewLayoutLoaded = false

    private var selectedBackup: AlgorandSecureBackupFile?

    deinit {
        navigationBarLargeTitleController.deactivate()
    }

    override func setListeners() {
        super.setListeners()

        navigationBarLargeTitleController.activate()
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        navigationBarLargeTitleController.title = theme.navigationTitle
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isViewLayoutLoaded {
            return
        }

        updateUIWhenViewDidLayoutSubviews()

        isViewLayoutLoaded = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
        bindData()
    }

    override func linkInteractors() {
        super.linkInteractors()

        uploadView.startObserving(event: .performClick) {
            let documentPicker: UIDocumentPickerViewController
            if #available(iOS 14.0, *) {
                documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.text, .plainText])
            } else {
                documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeText as String, kUTTypePlainText as String], in: .import)
            }
            documentPicker.allowsMultipleSelection = false
            documentPicker.shouldShowFileExtensions = true
            documentPicker.delegate = self
            self.present(documentPicker, animated: true)
        }
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

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        navigationBarLargeTitleController.scrollViewWillEndDragging(
            withVelocity: velocity,
            targetContentOffset: targetContentOffset,
            contentOffsetDeltaYBelowLargeTitle: 0
        )
    }

    private func addUI() {
        addBackground()
        addNavigationBarLargeTitle()
        addHeader()
        addActions()
        addNextAction()
    }

    override func bindData() {
        super.bindData()

        bindUploadView(for: .empty)
    }
}

// MARK: UI functions
extension AlgorandSecureBackupImportBackupScreen {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addNavigationBarLargeTitle() {
        view.addSubview(navigationBarLargeTitleView)
        navigationBarLargeTitleView.snp.makeConstraints {
            $0.setPaddings(
                theme.navigationBarEdgeInset
            )
        }
    }

    private func addHeader() {
        headerView.customizeAppearance(theme.header)

        contentView.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top == theme.defaultInset
            $0.leading == theme.defaultInset
            $0.trailing == theme.defaultInset
        }
    }

    private func addActions() {
        uploadView.customize(AlgorandSecureBackupImportFileViewTheme())
        
        contentView.addSubview(uploadView)
        uploadView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(theme.uploadTopOffset)
            $0.leading == theme.defaultInset
            $0.trailing == theme.defaultInset
            $0.height.equalTo(theme.uploadHeight)
        }
        contentView.addSubview(actionsView)
        actionsView.spacing = theme.actionsPadding
        actionsView.snp.makeConstraints {
            $0.top.equalTo(uploadView.snp.bottom).offset(theme.actionsTopOffset)
            $0.leading == theme.defaultInset
            $0.trailing == theme.defaultInset
            $0.bottom.greaterThanOrEqualToSuperview().inset(theme.defaultInset)
        }
        addPasteAction()
    }

    private func addPasteAction() {
        pasteActionView.customizeAppearance(theme.pasteAction)
        pasteActionView.titleEdgeInsets = theme.pasteActionTitleEdgeInsets

        pasteActionView.addTouch(
            target: self,
            action: #selector(performPasteAction)
        )

        actionsView.addArrangedSubview(pasteActionView)
    }

    private func addNextAction() {
        nextActionView.customizeAppearance(theme.nextAction)
        nextActionView.contentEdgeInsets = theme.nextActionContentEdgeInsets

        footerView.addSubview(nextActionView)
        nextActionView.snp.makeConstraints {
            $0.top == theme.nextActionEdgeInsets.top
            $0.leading == theme.nextActionEdgeInsets.leading
            $0.trailing == theme.nextActionEdgeInsets.trailing
            $0.bottom == theme.nextActionEdgeInsets.bottom
        }

        nextActionView.addTouch(
            target: self,
            action: #selector(performNextAction)
        )

        updateNextActionEnable()
    }
}

// MARK: Helpers
extension AlgorandSecureBackupImportBackupScreen {
    private func updateUIWhenViewDidLayoutSubviews() {
        updateAdditionalSafeAreaInetsWhenViewDidLayoutSubviews()
    }

    private func updateAdditionalSafeAreaInetsWhenViewDidLayoutSubviews() {
        scrollView.contentInset.top = navigationBarLargeTitleView.bounds.height
    }
}

extension AlgorandSecureBackupImportBackupScreen {
    @objc
    private func performPasteAction() {
        defer {
            updateNextActionEnable()
        }

        guard
            let pasteBoardText = UIPasteboard.general.string,
            let data = Data(base64Encoded: pasteBoardText)
        else {
            bannerController?.presentErrorBanner(
                title: "algorand-secure-backup-import-backup-clipboard-failed-title".localized,
                message: "algorand-secure-backup-import-backup-clipboard-failed-subtitle".localized
            )
            return
        }

        let backup = AlgorandSecureBackupFile(data: data)

        selectedBackup = backup
        bindUploadView(for: .uploaded(backup))
    }

    @objc
    private func performNextAction() {
        guard let selectedBackup, hasValidData() else { return }
        eventHandler?(.backupSelected(selectedBackup), self)
    }

    private func updateNextActionEnable() {
        self.nextActionView.isEnabled = hasValidData()
    }

    private func hasValidData() -> Bool {
        guard let selectedBackup, selectedBackup.data != nil else { return false }
        return true
    }
}

extension AlgorandSecureBackupImportBackupScreen: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        pickBackupData(from: urls)
        updateNextActionEnable()
    }

    private func pickBackupData(from urls: [URL]) {
        do {
            let file = try createFile(from: urls.first!)
            self.selectedBackup = file
            bindUploadView(for: .uploaded(file))
        } catch {
            self.selectedBackup = nil

            if let fileError = error as? FileError {
                bindUploadView(for: .uploadFailed(fileError))
            } else {
                bindUploadView(for: .uploadFailed(.other(error)))
            }
        }
    }

    private func createFile(from url: URL) throws -> AlgorandSecureBackupFile {
        do {
            let urlDataInString = try String(contentsOf: url)
            guard Data(base64Encoded: urlDataInString) != nil else {
                throw FileError.invalid
            }
            return AlgorandSecureBackupFile(url: url)
        } catch {
            if let fileError = error as? FileError {
                throw fileError
            } else {
                throw FileError.other(error)
            }
        }
    }

    private func bindUploadView(for state: AlgorandSecureBackupImportFileViewModel.State) {
        let viewModel = AlgorandSecureBackupImportFileViewModel(state: state)
        uploadView.bindData(viewModel)
    }
}

extension AlgorandSecureBackupImportBackupScreen {
    enum Event {
        case backupSelected(AlgorandSecureBackupFile)
    }
}

extension AlgorandSecureBackupImportBackupScreen {
    enum FileError: Error {
        case unsupported
        case invalid
        case other(Error)
    }
}
