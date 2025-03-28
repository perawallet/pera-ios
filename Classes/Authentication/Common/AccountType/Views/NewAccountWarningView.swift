// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   NewAccountWarningView.swift

import UIKit

class NewAccountWarningView: UIView {
    
    init(theme: AccountTypeViewTheme) {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        loadView(theme: theme)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadView(theme: AccountTypeViewTheme) {
        let dashedView = DashedBorderView()
        dashedView.backgroundColor = .clear
        
        addSubview(dashedView)
        dashedView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(theme.dashedLineInset)
        }
        
        let view = UIView()
        
        let label = UILabel()
        label.customizeAppearance(theme.warning)
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        let icon = UIImageView()
        icon.customizeAppearance(theme.warningIcon)
        view.addSubview(icon)
        icon.snp.makeConstraints {
            $0.width.equalTo(theme.warningIconSize.w)
            $0.height.equalTo(theme.warningIconSize.h)
            $0.centerY.equalTo(label.snp.centerY)
            $0.leading.equalToSuperview().inset(theme.warningIconLeadingInset)
        }
        
        addSubview(view)
        view.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(theme.warningViewHorizontalInset)
            $0.leading.equalToSuperview().inset(theme.warningViewHorizontalInset)
            $0.top.equalToSuperview().inset(theme.warningViewTopInset)
            $0.height.equalTo(theme.warningViewHeight)
        }
    }
}


fileprivate class DashedBorderView: UIView {
    private var dashBorder = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBorder()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBorder()
    }

    private func setupBorder() {
        dashBorder.strokeColor = Colors.Wallet.wallet3.uiColor.cgColor
        dashBorder.lineDashPattern = [5, 3]
        dashBorder.lineWidth = 2
        dashBorder.fillColor = nil
        layer.addSublayer(dashBorder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        dashBorder.frame = bounds
        dashBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
    }
}
