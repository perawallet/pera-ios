//
//  QRScannerViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

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
    
    override func linkInteractors() {
        overlayView.delegate = self
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
        } else {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                        self.setupPreviewLayer()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.presentDisabledCameraAlert()
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
        
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        
        view.layer.addSublayer(previewLayer)
        
        view.addSubview(overlayView)
        overlayView.frame = previewLayer.frame
        
        captureSessionQueue.async {
            captureSession.startRunning()
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
            self.captureSession?.stopRunning()
        }
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                let qrString = readableObject.stringValue,
                let qrStringData = qrString.data(using: .utf8) else {
                    captureSession = nil
                    closeScreen(by: .pop)
                    delegate?.qrScannerViewController(self, didFail: .invalidData, then: nil)
                    return
            }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            if let qrText = try? JSONDecoder().decode(QRText.self, from: qrStringData) {
                captureSession = nil
                closeScreen(by: .pop)
                delegate?.qrScannerViewController(self, didRead: qrText, then: nil)
            } else if let url = URL(string: qrString),
                qrString.hasPrefix("algorand://") {
                guard let qrText = url.buildQRText() else {
                    delegate?.qrScannerViewController(self, didFail: .jsonSerialization, then: cameraResetHandler)
                    return
                }
                captureSession = nil
                closeScreen(by: .pop)
                delegate?.qrScannerViewController(self, didRead: qrText, then: nil)
            } else if AlgorandSDK().isValidAddress(qrString) {
                let qrText = QRText(mode: .address, address: qrString)
                captureSession = nil
                closeScreen(by: .pop)
                delegate?.qrScannerViewController(self, didRead: qrText, then: nil)
            } else {
                delegate?.qrScannerViewController(self, didFail: .jsonSerialization, then: cameraResetHandler)
                return
            }
        }
    }
}

extension QRScannerViewController: QRScannerOverlayViewDelegate {
    func qrScannerOverlayViewDidTapCancelButton(_ qrScannerOverlayView: QRScannerOverlayView) {
        closeScreen(by: .pop)
    }
}

extension QRScannerViewController {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let bottomInset: CGFloat = 20.0
        let buttonHorizontalInset: CGFloat = 20.0
    }
}

protocol QRScannerViewControllerDelegate: class {
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, then handler: EmptyHandler?)
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, then handler: EmptyHandler?)
}

enum QRScannerError: Error {
    case jsonSerialization
    case invalidData
}
