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

    private var selectedSecureBackup: SecureBackup?

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
        addUploadView()
        addPasteAction()
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

    private func addUploadView() {
        uploadView.customize(AlgorandSecureBackupImportFileViewTheme())

        contentView.addSubview(uploadView)
        uploadView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(theme.uploadTopOffset)
            $0.leading == theme.defaultInset
            $0.trailing == theme.defaultInset
            $0.height.equalTo(theme.uploadHeight)
        }
    }

    private func addPasteAction() {
        pasteActionView.customizeAppearance(theme.pasteAction)
        pasteActionView.titleEdgeInsets = theme.pasteActionTitleEdgeInsets

        pasteActionView.addTouch(
            target: self,
            action: #selector(performPasteAction)
        )

        contentView.addSubview(pasteActionView)
        pasteActionView.snp.makeConstraints {
            $0.top.equalTo(uploadView.snp.bottom).offset(theme.actionsTopOffset)
            $0.leading == theme.defaultInset
            $0.trailing == theme.defaultInset
            $0.bottom.greaterThanOrEqualToSuperview().inset(theme.defaultInset)
        }
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

        nextActionView.isEnabled = false
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
        loadingController?.startLoadingWithMessage("title-loading".localized)
        let pasteBoardText = UIPasteboard.general.string
        do {
            let secureBackup = try validateSecureBackup(from: pasteBoardText)
            loadingController?.stopLoading()
            eventHandler?(.backupSelected(secureBackup), self)
            bannerController?.presentSuccessBanner(
                title: "algorand-secure-backup-import-backup-clipboard-success-title".localized
            )
        } catch let error as ValidationError {
            loadingController?.stopLoading()
            presentErrorBanner(error: error)
        } catch {
            loadingController?.stopLoading()
            presentErrorBanner(error: .jsonSerialization)
        }
    }

    @objc
    private func performNextAction() {
        guard let selectedSecureBackup else {
            presentErrorBanner(error: .jsonSerialization)
            return
        }

        eventHandler?(.backupSelected(selectedSecureBackup), self)
    }
}

extension AlgorandSecureBackupImportBackupScreen: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        pickBackupData(from: urls)
    }

    private func pickBackupData(from urls: [URL]) {
        guard let url = urls.first else {
            presentErrorBanner(error: .wrongFormat)
            return
        }

        nextActionView.isEnabled = false

        do {
            let hasAccess = url.startAccessingSecurityScopedResource()
            guard hasAccess else {
                bindUploadView(for: .uploadFailed(.unauthorized))
                return
            }
            let string = try? String(contentsOf: url)
            let secureBackup = try validateSecureBackup(from: string)
            let fileName = try AlgorandSecureBackupFile(url: url).fileName
            bindUploadView(for: .uploaded(fileName: fileName))
            nextActionView.isEnabled = true
            selectedSecureBackup = secureBackup
            url.stopAccessingSecurityScopedResource()
        } catch let error as ValidationError {
            bindUploadView(for: .uploadFailed(error))
        } catch {
            bindUploadView(for: .uploadFailed(.jsonSerialization))
        }
    }

    private func bindUploadView(for state: AlgorandSecureBackupImportFileViewModel.State) {
        let viewModel = AlgorandSecureBackupImportFileViewModel(state: state)
        uploadView.bindData(viewModel)
    }

    private func validateSecureBackup(from string: String?) throws -> SecureBackup {
        guard let string, !string.isEmptyOrBlank else {
            throw ValidationError.emptySource
        }

        guard let data = Data(base64Encoded: string) else {
            throw ValidationError.wrongFormat
        }

        guard let secureBackup = try? SecureBackup.decoded(data) else {
            throw ValidationError.jsonSerialization
        }

        guard secureBackup.hasValidVersion() else {
            throw ValidationError.unsupportedVersion
        }

        guard secureBackup.hasValidSuite() else {
            throw ValidationError.cipherSuiteUnknown
        }

        guard secureBackup.hasValidCipherText() else {
            throw ValidationError.cipherSuiteInvalid
        }

        return secureBackup
    }
}

/// <mark>: Error Handling
extension AlgorandSecureBackupImportBackupScreen {
    private func presentErrorBanner(error: ValidationError) {
        let title: String
        let message: String

        switch error {
        case .emptySource:
            title = "algorand-secure-backup-import-backup-clipboard-failed-title".localized
            message = "algorand-secure-backup-import-backup-clipboard-failed-subtitle".localized
        case .wrongFormat:
            title = "algorand-secure-backup-import-backup-clipboard-json-failed-title".localized
            message = ""
        case .unsupportedVersion:
            title = "algorand-secure-backup-import-backup-clipboard-version-failed-title".localized
            message = ""
        case .cipherSuiteUnknown, .cipherSuiteInvalid:
            title = "algorand-secure-backup-import-backup-clipboard-cipher-suite-failed-title".localized
            message = ""
        case .jsonSerialization:
            title = "algorand-secure-backup-import-backup-clipboard-json-failed-title".localized
            message = ""
        case .unauthorized:
            title = "algorand-secure-backup-import-backup-clipboard-unauthorized-failed-title".localized
            message = ""
        }

        bannerController?.presentErrorBanner(
            title: title,
            message: message
        )
    }
}

extension AlgorandSecureBackupImportBackupScreen {
    enum Event {
        case backupSelected(SecureBackup)
    }
}

extension AlgorandSecureBackupImportBackupScreen {
    enum ValidationError: Error {
        case emptySource
        case wrongFormat // It should be base 64
        case jsonSerialization
        case unsupportedVersion
        case cipherSuiteUnknown
        case cipherSuiteInvalid
        case unauthorized
    }
}
