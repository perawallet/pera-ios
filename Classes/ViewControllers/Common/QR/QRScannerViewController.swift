//
//  QRScannerViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import AVFoundation

enum QRScannerError: Error {
    case jsonSerialization
    case invalidData
}

protocol QRScannerViewControllerDelegate: class {
    
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, then handler: EmptyHandler?)
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, then handler: EmptyHandler?)
}

class QRScannerViewController: BaseViewController {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let bottomInset: CGFloat = 20.0
        let buttonHorizontalInset: CGFloat = MainButton.Constants.horizontalInset
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Configuration
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var hidesCloseBarButtonItem: Bool {
        return true
    }
    
    // MARK: Components
    
    private(set) lazy var cancelButton: MainButton = {
        let button = MainButton(title: "title-close".localized)
        return button
    }()
    
    private(set) lazy var overlayView: QRScannerOverlayView = {
        let view = QRScannerOverlayView()
        return view
    }()
    
    weak var delegate: QRScannerViewControllerDelegate?
    
    private var captureSession: AVCaptureSession?
    private let captureSessionQueue = DispatchQueue(label: AVCaptureSession.self.description(), attributes: [], target: nil)
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private lazy var cameraResetHandler: EmptyHandler = {
        if self.captureSession?.isRunning == false {
            self.captureSessionQueue.async {
                self.captureSession?.startRunning()
            }
        }
    }
    
    override init(configuration: ViewControllerConfiguration) {
        super.init(configuration: configuration)
        
        hidesBottomBarWhenPushed = true
    }
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "qr-scan-title".localized
    }
    
    override func setListeners() {
        super.setListeners()
        
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupCancelButtonLayout()
        configureScannerView()
    }
    
    private func setupCancelButtonLayout() {
        view.addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(layout.current.bottomInset + view.safeAreaBottom)
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func configureScannerView() {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            setupCaptureSession()
            setupPreviewLayer()
        } else {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                        self.setupPreviewLayer()
                    }
                } else {
                    self.presentDisabledCameraAlert()
                }
            }
        }
    }
    
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
        
        let cancelAction = UIAlertAction(title: "title-cancel-lowercased".localized, style: .cancel, handler: nil)
        
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
        
        previewLayer.frame = CGRect(
            x: 0,
            y: 80.0,
            width: view.frame.width,
            height: 5 * (view.frame.height - view.safeAreaTop - view.safeAreaBottom) / 8
        )
        previewLayer.videoGravity = .resizeAspectFill
        
        view.layer.addSublayer(previewLayer)
        
        view.addSubview(overlayView)
        overlayView.frame = previewLayer.frame
        
        captureSessionQueue.async {
            captureSession.startRunning()
        }
    }
    
    // MARK: View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if captureSession?.isRunning == false {
            captureSessionQueue.async {
                self.captureSession?.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession?.isRunning == true {
            captureSessionQueue.async {
                self.captureSession?.stopRunning()
            }
        }
    }
    
    // MARK: Actions
    
    @objc
    private func didTapCancelButton() {
        closeScreen(by: .pop)
    }
}

// MARK: AVCaptureMetadataOutputObjectsDelegate

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        captureSession?.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                let qrStringData = readableObject.stringValue?.data(using: .utf8) else {
                    delegate?.qrScannerViewController(self, didFail: .invalidData, then: cameraResetHandler)
                    return
            }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            guard let qrText = try? JSONDecoder().decode(QRText.self, from: qrStringData) else {
                delegate?.qrScannerViewController(self, didFail: .jsonSerialization, then: cameraResetHandler)
                return
            }
            
            delegate?.qrScannerViewController(self, didRead: qrText, then: cameraResetHandler)
            closeScreen(by: .pop)
        }
    }
}
