//
//  QRView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 28.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class QRView: UIView {
    private let outputWidth: CGFloat = 200.0
    
    private(set) lazy var imageView: UIImageView = {
       UIImageView()
    }()

    private let qrText: QRText
    
    init(qrText: QRText) {
        self.qrText = qrText
        super.init(frame: .zero)
        
        setupLayout()
        
        generateQR()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout
extension QRView {
    fileprivate func setupLayout() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - Helpers
extension QRView {
    fileprivate func generateQR() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(qrText)
            
            guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return }
            
            qrFilter.setDefaults()
            qrFilter.setValue(data, forKey: "inputMessage")
            
            guard let ciImage = qrFilter.outputImage else {
                return
            }
            
            let ciImageSize = ciImage.extent.size
            let ratio = outputWidth / ciImageSize.width
            
            guard let outputImage = ciImage.nonInterpolatedImage(withScale: Scale(dx: ratio, dy: ratio)) else {
                return
            }
            
            imageView.image = outputImage
        } catch {
            
        }
    }
}
