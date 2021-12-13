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
//  QRScannerView.swift

import UIKit
import MacaroonUIKit

final class QRScannerOverlayView: View {
    private lazy var theme = QRScannerOverlayViewTheme()

    private lazy var titleLabel = UILabel()
    private lazy var overlayView = UIView()
    private lazy var overlayImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
    }

    private func customize(_ theme: QRScannerOverlayViewTheme) {
        addOverlayView(theme)
        addOverlayImageView(theme)
        addTitleLabel(theme)
    }

    func prepareLayout(_ layoutSheet: LayoutSheet) {}

    func customizeAppearance(_ styleSheet: StyleSheet) {}
}

extension QRScannerOverlayView {
    private func addOverlayView(_ theme: QRScannerOverlayViewTheme) {
        overlayView.frame =  UIScreen.main.bounds
        overlayView.backgroundColor = theme.backgroundColor.uiColor
        let path = CGMutablePath()
        path.addRect(UIScreen.main.bounds)
        let size = theme.overlayViewSize
        let rect = CGRect(x: UIScreen.main.bounds.midX - (size / 2), y: UIScreen.main.bounds.midY - (size / 2), width: size, height: size)
        path.addRoundedRect(
            in: rect,
            cornerWidth: theme.overlayCornerRadius,
            cornerHeight: theme.overlayCornerRadius
        )
        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        overlayView.layer.mask = maskLayer

        addSubview(overlayView)
    }
    
    private func addOverlayImageView(_ theme: QRScannerOverlayViewTheme) {
        overlayImageView.customizeAppearance(theme.overlayImage)

        let size = theme.overlayImageViewSize
        let frame = CGRect(x: UIScreen.main.bounds.midX - (size / 2), y: UIScreen.main.bounds.midY - (size / 2), width: size, height: size)
        overlayImageView.frame = frame

        addSubview(overlayImageView)
    }
    
    private func addTitleLabel(_ theme: QRScannerOverlayViewTheme) {
        titleLabel.customizeAppearance(theme.title)

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.trailing.leading.equalToSuperview().inset(theme.horizontalInset)
            $0.top.equalToSuperview().offset(theme.titleLabelTopInset)
        }
    }
}
