//
//  QRView.swift

import UIKit

class QRView: BaseView {
    
    private let outputWidth: CGFloat = 200.0
    
    private(set) lazy var imageView = UIImageView()

    let qrText: QRText
    
    init(qrText: QRText) {
        self.qrText = qrText
        super.init(frame: .zero)
        
        if qrText.mode == .mnemonic {
            generateMnemonicsQR()
        } else {
            generateLinkQR()
        }
    }
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        setupImageViewLayout()
    }
}

extension QRView {
    private func setupImageViewLayout() {
        addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension QRView {
    private func generateLinkQR() {
        guard let data = qrText.qrText().data(using: .ascii) else {
            return
        }
        generateQR(from: data)
    }
    
    private func generateMnemonicsQR() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(qrText)
            generateQR(from: data)
        } catch { }
    }
    
    private func generateQR(from data: Data) {
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return
        }
        
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
    }
}
