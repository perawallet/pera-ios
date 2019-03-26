//
//  QRScannerView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 25.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class QRScannerOverlayView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let qrIconImageViewVerticalInset: CGFloat = -15.0
    }
    
    private enum Colors {
        static let overlayColor = rgba(0.04, 0.05, 0.07, 0.5)
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private lazy var qrIconImageView = UIImageView(image: img("icon-qr-code-white"))
    
    private(set) lazy var overlayImageView = UIImageView(image: img("bg-dotted-rect"))
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        setupOverlayImageViewLayout()
        setupQRDisplayViewLayout()
        setupQRIconImageViewLayout()
    }
    
    private func setupOverlayImageViewLayout() {
        addSubview(overlayImageView)
        
        overlayImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupQRDisplayViewLayout() {
        let topOverlayView = UIView()
        topOverlayView.backgroundColor = Colors.overlayColor
        
        addSubview(topOverlayView)
        
        topOverlayView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(overlayImageView.snp.top)
        }
        
        let bottomOverlayView = UIView()
        bottomOverlayView.backgroundColor = Colors.overlayColor
        
        addSubview(bottomOverlayView)
        
        bottomOverlayView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(overlayImageView.snp.bottom)
        }
        
        let leftOverlayView = UIView()
        leftOverlayView.backgroundColor = Colors.overlayColor
        
        addSubview(leftOverlayView)
        
        leftOverlayView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(topOverlayView.snp.bottom)
            make.bottom.equalTo(bottomOverlayView.snp.top)
            make.trailing.equalTo(overlayImageView.snp.leading)
        }
        
        let rightOverlayView = UIView()
        rightOverlayView.backgroundColor = Colors.overlayColor
        
        addSubview(rightOverlayView)
        
        rightOverlayView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(topOverlayView.snp.bottom)
            make.bottom.equalTo(bottomOverlayView.snp.top)
            make.leading.equalTo(overlayImageView.snp.trailing)
        }
    }
    
    private func setupQRIconImageViewLayout() {
        addSubview(qrIconImageView)
        
        qrIconImageView.snp.makeConstraints { make in
            make.bottom.equalTo(overlayImageView.snp.top).offset(layout.current.qrIconImageViewVerticalInset)
            make.centerX.equalToSuperview()
        }
    }
}
