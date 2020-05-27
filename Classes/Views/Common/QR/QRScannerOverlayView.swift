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
            .withTextColor(SharedColors.white)
            .withText("qr-scan-title".localized)
            .withLine(.single)
            .withAlignment(.center)
    }()
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18.0
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var topLeftOverlayImageView = UIImageView(image: img("img-qr-overlay-top-left"))
    
    private lazy var topRightOverlayImageView = UIImageView(image: img("img-qr-overlay-top-right"))
    
    private lazy var bottomLeftOverlayImageView = UIImageView(image: img("img-qr-overlay-bottom-left"))
    
    private lazy var bottomRightOverlayImageView = UIImageView(image: img("img-qr-overlay-bottom-right"))
    
    private lazy var explanationLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(withWeight: .regular(size: 14.0)))
            .withTextColor(SharedColors.white.withAlphaComponent(0.8))
            .withText("qr-scan-message-text".localized)
            .withLine(.contained)
            .withAlignment(.center)
    }()
    
    private lazy var cancelButton: UIButton = {
        UIButton(type: .custom)
            .withBackgroundImage(img("button-bg-scan-qr"))
            .withTitle("title-cancel".localized)
            .withTitleColor(SharedColors.primaryButtonTitle)
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
        setupTopLeftOverlayImageViewLayout()
        setupTopRightOverlayImageViewLayout()
        setupBottomLeftOverlayImageViewLayout()
        setupBottomRightOverlayImageViewLayout()
        setupQRDisplayViewLayout()
        setupTitleLabelLayout()
        setupCancelButtonLayout()
        setupExplanationLabelLayout()
    }
}

extension QRScannerOverlayView {
    @objc
    private func notifyDelegateToCloseScreen() {
        delegate?.qrScannerOverlayViewDidTapCancelButton(self)
    }
}

extension QRScannerOverlayView {
    private func setupOverlayViewLayout() {
        addSubview(overlayView)
        
        overlayView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(layout.current.overlaySize)
        }
    }
    
    private func setupTopLeftOverlayImageViewLayout() {
        overlayView.addSubview(topLeftOverlayImageView)
        
        topLeftOverlayImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
    }
    
    private func setupTopRightOverlayImageViewLayout() {
        overlayView.addSubview(topRightOverlayImageView)
        
        topRightOverlayImageView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
        }
    }
    
    private func setupBottomLeftOverlayImageViewLayout() {
        overlayView.addSubview(bottomLeftOverlayImageView)
        
        bottomLeftOverlayImageView.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview()
        }
    }
    
    private func setupBottomRightOverlayImageViewLayout() {
        overlayView.addSubview(bottomRightOverlayImageView)
        
        bottomRightOverlayImageView.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview()
        }
    }
    
    private func setupQRDisplayViewLayout() {
        let topOverlayView = UIView()
        topOverlayView.backgroundColor = SharedColors.gray900.withAlphaComponent(0.9)
        
        addSubview(topOverlayView)
        
        topOverlayView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(overlayView.snp.top)
        }
        
        let bottomOverlayView = UIView()
        bottomOverlayView.backgroundColor = SharedColors.gray900.withAlphaComponent(0.9)
        
        addSubview(bottomOverlayView)
        
        bottomOverlayView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(overlayView.snp.bottom)
        }
        
        let leftOverlayView = UIView()
        leftOverlayView.backgroundColor = SharedColors.gray900.withAlphaComponent(0.9)
        
        addSubview(leftOverlayView)
        
        leftOverlayView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(topOverlayView.snp.bottom)
            make.bottom.equalTo(bottomOverlayView.snp.top)
            make.trailing.equalTo(overlayView.snp.leading)
        }
        
        let rightOverlayView = UIView()
        rightOverlayView.backgroundColor = SharedColors.gray900.withAlphaComponent(0.9)
        
        addSubview(rightOverlayView)
        
        rightOverlayView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(topOverlayView.snp.bottom)
            make.bottom.equalTo(bottomOverlayView.snp.top)
            make.leading.equalTo(overlayView.snp.trailing)
        }
    }
    
    private func setupTitleLabelLayout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.titleLabelTopInset)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupCancelButtonLayout() {
        addSubview(cancelButton)
        
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(layout.current.buttonVerticalInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
        }
    }
    
    private func setupExplanationLabelLayout() {
        addSubview(explanationLabel)
        
        explanationLabel.snp.makeConstraints { make in
            make.bottom.equalTo(cancelButton.snp.top).offset(-layout.current.buttonVerticalInset)
            make.top.greaterThanOrEqualTo(overlayView.snp.bottom).offset(layout.current.explanationLabelTopInset)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(layout.current.explanationLabelHorizontalInset)
        }
    }
}

extension QRScannerOverlayView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let horizontalInset: CGFloat = 20.0
        let buttonVerticalInset: CGFloat = 40.0 * verticalScale
        let titleLabelTopInset: CGFloat = 40.0
        let overlaySize = CGSize(width: 248.0, height: 248.0)
        let explanationLabelHorizontalInset: CGFloat = 40.0
        let explanationLabelTopInset: CGFloat = 20.0 * verticalScale
    }
}

protocol QRScannerOverlayViewDelegate: class {
    func qrScannerOverlayViewDidTapCancelButton(_ qrScannerOverlayView: QRScannerOverlayView)
}
