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
//  QRScannerViewController.swift

import UIKit
import AVFoundation
import MacaroonUtils
import MacaroonUIKit

final class QRScannerViewController:
    BaseViewController,
    NotificationObserver,
    PeraConnectObserver {
    weak var delegate: QRScannerViewControllerDelegate?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldShowNavigationBar: Bool {
        return false
    }

    var notificationObservations: [NSObjectProtocol] = []

    private lazy var wcConnectionModalTransition = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )

    private lazy var overlayView = QRScannerOverlayView {
        [weak self] in
        guard let self = self else { return }

        $0.cancelMode = self.canGoBack() ? .pop : .dismiss
        $0.showsConnectedAppsButton = self.isShowingConnectedAppsButton
    }
    
    private var captureSession: AVCaptureSession?
    private let captureSessionQueue = DispatchQueue(label: AVCaptureSession.self.description(), attributes: [], target: nil)
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var walletConnectSessionCreationPreferences: WalletConnectSessionCreationPreferences?

    private lazy var cameraResetHandler: EmptyHandler = {
        if self.captureSession?.isRunning == false {
            self.captureSessionQueue.async {
                [weak self] in
                guard let self else { return }
                self.captureSession?.startRunning()
            }
        }
    }

    private let canReadWCSession: Bool
    private var wcConnectionRepeater: Repeater?

    private lazy var isShowingConnectedAppsButton: Bool = {
        let sessions = peraConnect.walletConnectCoordinator.getSessions()
        return canReadWCSession && !sessions.isEmpty
    }()

    init(canReadWCSession: Bool, configuration: ViewControllerConfiguration) {
        self.canReadWCSession = canReadWCSession
        super.init(configuration: configuration)
    }

    deinit {
        wcConnectionRepeater?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.Defaults.background.uiColor

        peraConnect.add(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        enableCapturingIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        disableCapturingIfNeeded()
    }

    override func prepareLayout() {
        super.prepareLayout()

        configureScannerView()
    }

    override func bindData() {
        super.bindData()

        if isShowingConnectedAppsButton {
            bindOverlay()
        }
    }

    override func setListeners() {
        overlayView.delegate = self
    }

    override func linkInteractors() {
        super.linkInteractors()

        observeWhenApplicationDidEnterBackground {
            [weak self] _ in
            guard let self = self else { return }
            self.disableCapturingIfNeeded()
        }
    }
}

extension QRScannerViewController {
    private func enableCapturingIfNeeded() {
        if self.captureSession?.isRunning == false && UIApplication.shared.authStatus == .ready {
            self.captureSessionQueue.async {
                [weak self] in
                guard let self else { return }
                self.captureSession?.startRunning()
            }
        }
    }

    private func disableCapturingIfNeeded() {
        if captureSession?.isRunning == true {
            captureSessionQueue.async {
                [weak self] in
                guard let self else { return }
                self.captureSession?.stopRunning()
            }
        }
    }
}

extension QRScannerViewController {
    private func configureScannerView() {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            setupCaptureSession()
            setupPreviewLayer()
            setupOverlayViewLayout()
        } else {
            AVCaptureDevice.requestAccess(for: .video) {
                [weak self] granted in
                guard let self else { return }

                if granted {
                    DispatchQueue.main.async {
                        [weak self] in
                        guard let self else { return }
                        self.setupCaptureSession()
                        self.setupPreviewLayer()
                        self.setupOverlayViewLayout()
                    }
                } else {
                    DispatchQueue.main.async {
                        [weak self] in
                        guard let self else { return }
                        self.presentDisabledCameraAlert()
                        self.setupOverlayViewLayout()
                    }
                }
            }
        }
    }
}

extension QRScannerViewController {
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()

        guard let captureSession = captureSession,
              let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            handleFailedState()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            handleFailedState()
            return
        }
    }

    private func presentDisabledCameraAlert() {
        let alertController = UIAlertController(
            title: "qr-scan-go-settings-title".localized,
            message: "qr-scan-go-settings-message".localized,
            preferredStyle: .alert
        )

        let settingsAction = UIAlertAction(title: "title-go-to-settings".localized, style: .default) { _ in
            UIApplication.shared.openAppSettings()
        }

        let cancelAction = UIAlertAction(title: "title-cancel".localized, style: .cancel, handler: nil)

        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    private func handleFailedState() {
        captureSession = nil
        displaySimpleAlertWith(title: "qr-scan-error-title".localized, message: "qr-scan-error-message".localized)
    }

    private func setupPreviewLayer() {
        guard let captureSession = captureSession else {
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        guard let previewLayer = previewLayer else {
            return
        }

        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill

        view.layer.addSublayer(previewLayer)

        captureSessionQueue.async {
            [weak captureSession] in
            guard let captureSession else { return }
            captureSession.startRunning()
        }
    }

    private func setupOverlayViewLayout() {
        overlayView.customize(QRScannerOverlayViewTheme())
        view.addSubview(overlayView)
        overlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension QRScannerViewController {
    private func closeScreen() {
        if canGoBack() {
            popScreen()
        } else {
            dismissScreen()
        }
    }
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        captureSessionQueue.async {
            [weak self] in
            guard let self else { return }
            self.captureSession?.stopRunning()
        }

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                  let qrString = readableObject.stringValue,
                  let qrStringData = qrString.data(using: .utf8) else {
                captureSession = nil
                closeScreen()
                delegate?.qrScannerViewController(self, didFail: .invalidData, completionHandler: nil)
                return
            }

            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            if peraConnect.isValidSession(qrString) {
                if !canReadWCSession {
                    bannerController?.presentErrorBanner(
                        title: "title-error".localized,
                        message: "qr-scan-invalid-wc-screen-error".localized
                    )
                    captureSession = nil
                    closeScreen()
                    return
                }
                
                let preferences = WalletConnectSessionCreationPreferences(session: qrString)
                self.walletConnectSessionCreationPreferences = preferences
                peraConnect.connectToSession(with: preferences)
                startWCConnectionTimer()
                return
            } else if let qrBackupParameters = try? JSONDecoder().decode(QRBackupParameters.self, from: qrStringData) {
                captureSession = nil
                closeScreen()
                delegate?.qrScannerViewController(self, didRead: qrBackupParameters, completionHandler: nil)
            } else if let qrText = try? JSONDecoder().decode(QRText.self, from: qrStringData) {
                captureSession = nil
                closeScreen()
                delegate?.qrScannerViewController(self, didRead: qrText, completionHandler: nil)
            } else if let url = URL(string: qrString),
                      let scheme = url.scheme,
                      target.deeplinkConfig.qr.canAcceptScheme(scheme) {

                let deeplinkQR = DeeplinkQR(url: url)
                guard let qrText = deeplinkQR.qrText() else {
                    delegate?.qrScannerViewController(self, didFail: .jsonSerialization, completionHandler: cameraResetHandler)
                    return
                }
                captureSession = nil
                closeScreen()
                delegate?.qrScannerViewController(self, didRead: qrText, completionHandler: nil)
            } else if qrString.isValidatedAddress {
                let qrText = QRText(mode: .address, address: qrString)
                captureSession = nil
                closeScreen()
                delegate?.qrScannerViewController(self, didRead: qrText, completionHandler: nil)
            } else if let qrBackupParameters = try? JSONDecoder().decode(QRBackupParameters.self, from: qrStringData) {
                captureSession = nil
                closeScreen()
                delegate?.qrScannerViewController(self, didRead: qrBackupParameters, completionHandler: nil)
            } else {
                delegate?.qrScannerViewController(self, didFail: .jsonSerialization, completionHandler: cameraResetHandler)
                return
            }
        }
    }
}

extension QRScannerViewController {
    func peraConnect(
        _ peraConnect: PeraConnect,
        didPublish event: PeraConnectEvent
    ) {
        switch event {
        case .shouldStartV1(let session, let preferences, let completion):
            shouldStartPeraConnect(
                session: session,
                with: preferences,
                then: completion
            )
        case .didConnectToV1(let session):
            peraConnectDidConnectToV1(
                session,
                with: walletConnectSessionCreationPreferences
            )
        case .didFailToConnectV1(let error):
            peraConnectDidFailToConnectV1(with: error)
        case .didExceedMaximumSessionFromV1:
            peraConnectDidExceedMaximumSessionFromV1()
        case .proposeSessionV2(let proposal):
            proposeSession(
                proposal,
                with: walletConnectSessionCreationPreferences
            )
        case .settleSessionV2(let session):
            peraConnectDidSettleSessionV2(
                session,
                with: walletConnectSessionCreationPreferences
            )
        case .didDisconnectFromV1:
            bindOverlay()
        case .didDisconnectFromV1Fail(_, let error):
            if case .failedToDisconnectInactiveSession = error {
                bindOverlay()
                return
            }
        case .didDisconnectFromV2:
            bindOverlay()
        case .deleteSessionV2:
            bindOverlay()
        default:
            break
        }
    }
}

extension QRScannerViewController {
    private func shouldStartPeraConnect(
        session: WalletConnectSession,
        with preferences: WalletConnectSessionCreationPreferences?,
        then completion: @escaping WalletConnectSessionConnectionCompletionHandler
    ) {
        stopWCConnectionTimer()
        let api = self.api!

        let sessionChainId = session.chainId(for: api.network)

        if !api.network.allowedChainIDs.contains(sessionChainId) {
            asyncMain { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: "wallet-connect-transaction-error-node".localized
                )
                
                completion(
                    session.getDeclinedWalletConnectionInfo(on: api.network)
                )
                
                self.resetUIForScanning()
            }
            return
        }

        let accounts = self.sharedDataController.accountCollection

        guard accounts.contains(where: { $0.value.authorization.isAuthorized }) else {
            asyncMain { [weak self] in
                guard let self = self else {
                    return
                }

                self.bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: "wallet-connect-session-error-no-account".localized
                )
                
                completion(
                    session.getDeclinedWalletConnectionInfo(on: api.network)
                )
            }
            return
        }

        asyncMain { [weak self] in
            guard let self = self else {
                return
            }

            let draft = WCSessionConnectionDraft(session: session)
            let wcConnectionScreen = self.wcConnectionModalTransition.perform(
                .wcConnection(draft: draft),
                by: .present
            ) as? WCSessionConnectionScreen
            
            wcConnectionScreen?.eventHandler = {
                [weak self, weak wcConnectionScreen] event in
                guard let self,
                      let wcConnectionScreen else {
                    return
                }
                
                switch event {
                case .performCancel:
                    analytics.track(
                        .wcSessionRejected(
                            topic: session.url.topic,
                            dappName: session.dAppInfo.peerMeta.name,
                            dappURL: session.dAppInfo.peerMeta.url.absoluteString
                        )
                    )
                    
                    DispatchQueue.main.async {
                        [weak self] in
                        guard let self else { return }
                        
                        completion(
                            session.getDeclinedWalletConnectionInfo(on: self.api!.network)
                        )
                        
                        wcConnectionScreen.dismissScreen()
                        self.resetUIForScanning()
                    }
                case .performConnect(let accounts):
                    analytics.track(
                        .wcSessionApproved(
                            topic: session.url.topic,
                            dappName: session.dAppInfo.peerMeta.name,
                            dappURL: session.dAppInfo.peerMeta.url.absoluteString,
                            address: accounts.joined(separator: ","),
                            totalAccount: accounts.count
                        )
                    )
                    
                    DispatchQueue.main.async {
                        [weak self] in
                        guard let self else { return }
                        
                        completion(
                            session.getApprovedWalletConnectionInfo(
                                for: accounts,
                                on: self.api!.network
                            )
                        )
                        
                        wcConnectionScreen.dismiss(animated: true)
                    }
                }
            }
        }
    }

    func peraConnectDidConnectToV1(
        _ session: WCSession,
        with preferences: WalletConnectSessionCreationPreferences?
    ) {

        let shouldShowConnectionApproval = preferences?.prefersConnectionApproval ?? false
        if shouldShowConnectionApproval {
            let draft = WCSessionDraft(wcV1Session: session)
            openWCSessionConnectionSuccessful(draft)
        }

        captureSession = nil
        walletConnector.saveConnectedWCSession(session)
        walletConnector.clearExpiredSessionsIfNeeded()
    }
    
    func peraConnectDidFailToConnectV1(with error: WalletConnectV1Protocol.WCError) {
        switch error {
        case .failedToConnect,
                .failedToCreateSession:

            asyncMain { [weak self] in
                guard let self = self else {
                    return
                }

                self.resetUIForScanning()
                self.bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: "wallet-connect-session-invalid-qr-message".localized
                )
                self.captureSession = nil
            }
        default:
            break
        }
    }
    
    func peraConnectDidExceedMaximumSessionFromV1() {
        delegate?.qrScannerViewControllerDidExceededMaximumWCSessionLimit(self)
    }

    private func startWCConnectionTimer() {
        /// We need to warn the user after 10 seconds if there's no resposne from the dApp.
        wcConnectionRepeater = Repeater(intervalInSeconds: 10.0) { [weak self] in
            guard let self = self else {
                return
            }

            asyncMain { [weak self] in
                guard let self = self else {
                    return
                }

                if self.captureSession?.isRunning == true {
                    self.captureSessionQueue.async {
                        self.captureSession?.stopRunning()
                    }
                }

                self.presentWCConnectionError()
            }

            self.stopWCConnectionTimer()
        }

        wcConnectionRepeater?.resume(immediately: false)
    }

    private func stopWCConnectionTimer() {
        wcConnectionRepeater?.invalidate()
        wcConnectionRepeater = nil
    }

    private func presentWCConnectionError() {
        bannerController?.presentErrorBanner(
            title: "title-failed-connection".localized,
            message: "wallet-connect-session-timeout-message".localized
        )
    }
}

extension QRScannerViewController {
    private func proposeSession(
        _ sessionProposal: WalletConnectV2SessionProposal,
        with preferences: WalletConnectSessionCreationPreferences?
    ) {
        stopWCConnectionTimer()

        let accounts = self.sharedDataController.accountCollection

        guard accounts.contains(where: { $0.value.authorization.isAuthorized }) else {
            asyncMain { [weak self] in
                guard let self = self else {
                    return
                }

                self.bannerController?.presentErrorBanner(
                    title: "title-error".localized,
                    message: "wallet-connect-session-error-no-account".localized
                )
                
                let params = WalletConnectV2RejectSessionConnectionParams(
                    proposalId: sessionProposal.id,
                    reason: .userRejected
                )
                peraConnect.rejectSessionConnection(params)
            }
            return
        }

        let draft = WCSessionConnectionDraft(sessionProposal: sessionProposal)

        asyncMain {
            [weak self] in
            guard let self = self else { return }

            let wcConnectionScreen = self.wcConnectionModalTransition.perform(
                .wcConnection(draft: draft),
                by: .present
            ) as? WCSessionConnectionScreen
           
            wcConnectionScreen?.eventHandler = {
                [weak self, weak wcConnectionScreen] event in
                guard let self = self else { return }

                switch event {
                case .performCancel:
                    analytics.track(
                        .wcSessionRejected(
                            topic: sessionProposal.pairingTopic,
                            dappName: sessionProposal.proposer.name,
                            dappURL: sessionProposal.proposer.url
                        )
                    )
                    
                    asyncMain {
                        [weak self, weak wcConnectionScreen] in
                        guard let self else { return }
                        
                        let params = WalletConnectV2RejectSessionConnectionParams(
                            proposalId: sessionProposal.id,
                            reason: .userRejected
                        )
                        peraConnect.rejectSessionConnection(params)
                        
                        wcConnectionScreen?.dismissScreen()
                        self.resetUIForScanning()
                    }
                case .performConnect(let selectedAccounts):
                    analytics.track(
                        .wcSessionApproved(
                            topic: sessionProposal.pairingTopic,
                            dappName: sessionProposal.proposer.name,
                            dappURL: sessionProposal.proposer.url,
                            address: selectedAccounts.joined(separator: ","),
                            totalAccount: selectedAccounts.count
                        )
                    )
                    
                    var sessionNamespaces = SessionNamespaces()
                    sessionProposal.requiredNamespaces.forEach {
                        let caip2Namespace = $0.key
                        let proposalNamespace = $0.value
                          
                        guard let chains = proposalNamespace.chains else { return }
                       
                        let accounts = Set(
                            chains.compactMap { chain in
                                selectedAccounts.compactMap { account in
                                    return WalletConnectV2Account(
                                        "\(chain.absoluteString):\(account)"
                                    )
                                }
                            }
                        ).flatMap { $0 }
                           
                        let sessionNamespace = WalletConnectV2SessionNamespace(
                            accounts: Set(accounts),
                            methods: proposalNamespace.methods,
                            events: proposalNamespace.events
                        )
                           
                        sessionNamespaces[caip2Namespace] = sessionNamespace
                    }
                       
                    let params = WalletConnectV2ApproveSessionConnectionParams(proposalId: sessionProposal.id, namespaces: sessionNamespaces)
                    peraConnect.approveSessionConnection(params)
                    
                    wcConnectionScreen?.dismiss(animated: true)
                }
            }
        }
    }
    
    func peraConnectDidSettleSessionV2(
        _ session: WalletConnectV2Session,
        with preferences: WalletConnectSessionCreationPreferences?
    ) {
        if preferences?.prefersConnectionApproval ?? false {
            let draft = WCSessionDraft(wcV2Session: session)
            openWCSessionConnectionSuccessful(draft)
        }

        captureSession = nil
        walletConnector.clearExpiredSessionsIfNeeded()
    }
}

extension QRScannerViewController {
    private func resetUIForScanning() {
        captureSessionQueue.async {
            [weak self] in
            guard let self else { return }
            self.captureSession?.startRunning()
        }
    }
}

extension QRScannerViewController {
    private func openWCSessionConnectionSuccessful(_ draft: WCSessionDraft) {
        let eventHandler: WCSessionConnectionSuccessfulSheet.EventHandler = {
            [weak self] event in
            guard let self else { return }

            switch event {
            case .didClose:
                presentedViewController?.dismiss(animated: true) {
                    [weak self] in
                    guard let self else { return }
                    self.closeScreen()
                }
            }
        }
        wcConnectionModalTransition.perform(
            .wcSessionConnectionSuccessful(
                draft: draft,
                eventHandler: eventHandler
            ),
            by: .presentWithoutNavigationController
        )
    }
}

extension QRScannerViewController: QRScannerOverlayViewDelegate {
    func qrScannerOverlayViewDidTapConnectedAppsButton(_ qrScannerOverlayView: QRScannerOverlayView) {
        let walletConnectSessionsShortList: WCSessionShortListViewController? = wcConnectionModalTransition.perform(
            .walletConnectSessionShortList,
            by: .presentWithoutNavigationController
        )
        walletConnectSessionsShortList?.delegate = self
    }

    func qrScannerOverlayView(
        _ qrScannerOverlayView: QRScannerOverlayView,
        didCancel mode: QRScannerOverlayView.Configuration.CancelMode
    ) {
        switch mode {
        case .pop: popScreen()
        case .dismiss: dismissScreen()
        }
    }
}

extension QRScannerViewController: WCSessionShortListViewControllerDelegate {
    func wcSessionShortListViewControllerDidClose(_ controller: WCSessionShortListViewController) {
        bindOverlay()
    }
}

extension QRScannerViewController {
    private func bindOverlay() {
        let sessions = peraConnect.walletConnectCoordinator.getSessions()
        overlayView.bindData(
            QRScannerOverlayViewModel(dAppCount: UInt(sessions.count))
        )
    }
}

protocol QRScannerViewControllerDelegate: AnyObject {
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, completionHandler: EmptyHandler?)
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, completionHandler: EmptyHandler?)
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrBackupParameters: QRBackupParameters, completionHandler: EmptyHandler?)
    func qrScannerViewControllerDidExceededMaximumWCSessionLimit(_ controller: QRScannerViewController)
}

extension QRScannerViewControllerDelegate {
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, completionHandler: EmptyHandler?) {}
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, completionHandler: EmptyHandler?) {}
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrBackupParameters: QRBackupParameters, completionHandler: EmptyHandler?) {}
    func qrScannerViewControllerDidExceededMaximumWCSessionLimit(_ controller: QRScannerViewController) { }
}

enum QRScannerError: Swift.Error {
    case jsonSerialization
    case invalidData
}
