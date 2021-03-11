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
//  QRScannerViewController.swift

import UIKit
import AVFoundation

class QRScannerViewController: BaseViewController {
    
    private let layout = Layout<LayoutConstants>()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    override var hidesCloseBarButtonItem: Bool {
        return true
    }
    
    weak var delegate: QRScannerViewControllerDelegate?
    
    private(set) lazy var overlayView = QRScannerOverlayView()

    private lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("button-bg-scan-qr"))
            .withTitle("title-cancel".localized)
            .withTitleColor(Colors.Main.white)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
    }()
    
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

    override func setListeners() {
        cancelButton.addTarget(self, action: #selector(closeScreenFromButton), for: .touchUpInside)
    }

    override func prepareLayout() {
        super.prepareLayout()
        configureScannerView()
    }
}

extension QRScannerViewController {
    private func configureScannerView() {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            setupCaptureSession()
            setupPreviewLayer()
            setupOverlayViewLayout()
            setupCancelButtonLayout()
        } else {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                        self.setupPreviewLayer()
                        self.setupOverlayViewLayout()
                        self.setupCancelButtonLayout()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.presentDisabledCameraAlert()
                        self.setupOverlayViewLayout()
                        self.setupCancelButtonLayout()
                    }
                }
            }
        }
    }

    private func setupCancelButtonLayout() {
        view.addSubview(cancelButton)

        cancelButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(layout.current.buttonVerticalInset + view.safeAreaBottom)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.buttonHorizontalInset)
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
            captureSession.startRunning()
        }
    }

    private func setupOverlayViewLayout() {
        view.addSubview(overlayView)
        overlayView.frame = view.frame
    }
}

extension QRScannerViewController {
    @objc
    private func closeScreenFromButton() {
        closeScreen(by: .pop)
    }
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        captureSessionQueue.async {
            self.captureSession?.stopRunning()
        }
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                let qrString = readableObject.stringValue,
                let qrStringData = qrString.data(using: .utf8) else {
                    captureSession = nil
                    closeScreen(by: .pop)
                    delegate?.qrScannerViewController(self, didFail: .invalidData, completionHandler: nil)
                    return
            }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            if let qrText = try? JSONDecoder().decode(QRText.self, from: qrStringData) {
                captureSession = nil
                closeScreen(by: .pop)
                delegate?.qrScannerViewController(self, didRead: qrText, completionHandler: nil)
            } else if let url = URL(string: qrString),
                qrString.hasPrefix("algorand://") {
                guard let qrText = url.buildQRText() else {
                    delegate?.qrScannerViewController(self, didFail: .jsonSerialization, completionHandler: cameraResetHandler)
                    return
                }
                captureSession = nil
                closeScreen(by: .pop)
                delegate?.qrScannerViewController(self, didRead: qrText, completionHandler: nil)
            } else if AlgorandSDK().isValidAddress(qrString) {
                let qrText = QRText(mode: .address, address: qrString)
                captureSession = nil
                closeScreen(by: .pop)
                delegate?.qrScannerViewController(self, didRead: qrText, completionHandler: nil)
            } else {
                delegate?.qrScannerViewController(self, didFail: .jsonSerialization, completionHandler: cameraResetHandler)
                return
            }
        }
    }
}

extension QRScannerViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let buttonHorizontalInset: CGFloat = 20.0
        let buttonVerticalInset: CGFloat = 16.0
    }
}

protocol QRScannerViewControllerDelegate: class {
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, completionHandler: EmptyHandler?)
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, completionHandler: EmptyHandler?)
}

enum QRScannerError: Error {
    case jsonSerialization
    case invalidData
}
