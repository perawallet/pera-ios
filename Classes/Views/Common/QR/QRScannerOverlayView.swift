//
//  QRScannerView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class QRScannerOverlayView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    weak var delegate: QRScannerOverlayViewDelegate?
    
    private lazy var titleLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
            .withTextColor(Colors.Main.white)
            .withText("qr-scan-title".localized)
            .withLine(.single)
            .withAlignment(.center)
    }()
    
    private lazy var overlayView: UIView = {
        let overlayView = UIView(frame: UIScreen.main.bounds)
        overlayView.backgroundColor = Colors.QRScanner.qrScannerBackground
        let path = CGMutablePath()
        path.addRect(UIScreen.main.bounds)
        path.addRoundedRect(
            in: overlayViewCenterRect,
            cornerWidth: 18.0,
            cornerHeight: 18.0
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        overlayView.layer.mask = maskLayer
        return overlayView
    }()
    
    private lazy var overlayViewCenterRect: CGRect = {
        let size: CGFloat = 248.0
        return CGRect(x: UIScreen.main.bounds.midX - (size / 2.0), y: UIScreen.main.bounds.midY - (size / 2.0), width: size, height: size)
    }()
    
    private lazy var overlayImageView = UIImageView(image: img("img-qr-overlay-center"))
    
    private lazy var explanationLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(Colors.QRScanner.detailText)
            .withText("qr-scan-message-text".localized)
            .withLine(.contained)
            .withAlignment(.center)
    }()
    
    private lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("button-bg-scan-qr"))
            .withTitle("title-cancel".localized)
            .withTitleColor(Colors.QRScanner.buttonText)
            .withFont(UIFont.font(withWeight: .semiBold(size: 16.0)))
    }()
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func setListeners() {
        cancelButton.addTarget(self, action: #selector(notifyDelegateToCloseScreen), for: .touchUpInside)
    }
    
    override func prepareLayout() {
        setupOverlayViewLayout()
        setupOverlayImageViewLayout()
        setupTitleLabelLayout()
        setupCancelButtonLayout()
        setupExplanationLabelLayout()
    }
}

extension QRScannerOverlayView {
    @objc
    private func notifyDelegateToCloseScreen() {
        delegate?.qrScannerOverlayViewDidCancel(self)
    }
}

extension QRScannerOverlayView {
    private func setupOverlayViewLayout() {
        addSubview(overlayView)
        
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupOverlayImageViewLayout() {
        addSubview(overlayImageView)
        overlayImageView.frame = overlayViewCenterRect
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(safeAreaTop + layout.current.titleLabelTopInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupCancelButtonLayout() {
        addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(layout.current.buttonVerticalInset + safeAreaBottom)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupExplanationLabelLayout() {
        addSubview(explanationLabel)
        
        explanationLabel.snp.makeConstraints { make in
            make.bottom.equalTo(cancelButton.snp.top).offset(-layout.current.buttonVerticalInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.explanationLabelHorizontalInset)
        }
    }
}

extension Colors {
    fileprivate enum QRScanner {
        static let qrScannerBackground = color("qrScannerBackground")
        static let detailText = Colors.Main.white.withAlphaComponent(0.8)
        static let buttonText = Colors.Main.white
    }
}

extension QRScannerOverlayView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let buttonVerticalInset: CGFloat = 40.0
        let titleLabelTopInset: CGFloat = 20.0
        let explanationLabelHorizontalInset: CGFloat = 40.0
    }
}

protocol QRScannerOverlayViewDelegate: class {
    func qrScannerOverlayViewDidCancel(_ qrScannerOverlayView: QRScannerOverlayView)
}
