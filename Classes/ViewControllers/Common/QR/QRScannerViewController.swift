//
//  QRScannerViewController.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import AVFoundation

protocol QRScannerViewControllerDelegate: class {
    
    func qRScannerViewController(_ controller: QRScannerViewController, didRead qrCode: String)
}

class QRScannerViewController: BaseViewController {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let bottomInset: CGFloat = 20.0
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
    
    private(set) lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withFont(UIFont.font(.montserrat, withWeight: .bold(size: 14.0)))
            .withBackgroundImage(img("bg-dark-gray-button-big"))
            .withTitle("title-cancel".localized)
            .withTitleColor(SharedColors.black)
    }()
    
    private(set) lazy var overlayView: QRScannerOverlayView = {
        let view = QRScannerOverlayView()
        return view
    }()
    
    weak var delegate: QRScannerViewControllerDelegate?
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: Setup
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "recover-from-seed-title".localized
    }
    
    override func setListeners() {
        super.setListeners()
        
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupCancelButtonLayout()
        
        setupCaptureSession()
        setupPreviewLayer()
    }
    
    private func setupCancelButtonLayout() {
        view.addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(layout.current.bottomInset)
            make.centerX.equalToSuperview()
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
        
        previewLayer.frame = CGRect(x: 0, y: 3 * view.frame.height / 16, width: view.frame.width, height: 5 * view.frame.height / 8)
        previewLayer.videoGravity = .resizeAspectFill
        
        view.layer.addSublayer(previewLayer)
        
        view.addSubview(overlayView)
        overlayView.frame = previewLayer.frame
        
        captureSession.startRunning()
    }
    
    // MARK: View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if captureSession?.isRunning == false {
            captureSession?.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
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
                let qrStringValue = readableObject.stringValue else {
                    return
            }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            delegate?.qRScannerViewController(self, didRead: qrStringValue)
            closeScreen(by: .pop)
        }
    }
}
