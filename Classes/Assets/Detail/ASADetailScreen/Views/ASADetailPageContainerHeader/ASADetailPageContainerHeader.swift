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

//   ASADetailPageContainerHeader.swift

import UIKit
import SnapKit
import MacaroonUIKit

final class ASADetailPageContainerHeader: UICollectionReusableView {
    private lazy var containerView = UIStackView()
    private lazy var activityButton = Button()
    private lazy var aboutButton = Button()
    private lazy var selectedMarkerView: UIView = {
        let view = UIView()
        view.customizeAppearance(theme.selectedMarkerBackground)
        return view
    }()
    
    private var theme = ASADetailPageContainerHeaderTheme()
    
    var onActivityButtonPressed: (() -> Void)?
    var onAboutButtonPressed: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customizeAppearance(theme.background)
        addContainer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addContainer() {
        containerView.alignment = .fill
        containerView.distribution = .fillEqually
        containerView.axis = .horizontal
        
        addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.top == theme.buttonsViewTopPadding
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        let separatorView = UIView()
        separatorView.customizeAppearance(theme.separatorBackground)
        
        addSubview(separatorView)
        separatorView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(theme.separatorHeight)
        }
        
        addButtons()
    }
    
    private func addButtons() {
        activityButton.customizeAppearance(theme.activityButton)
        aboutButton.customizeAppearance(theme.aboutButton)
        
        [activityButton, aboutButton].forEach {
            containerView.addArrangedSubview($0)
        }
        
        activityButton.addTarget(self, action:  #selector(activityButtonPressed(_:)), for: .touchUpInside)
        aboutButton.addTarget(self, action:  #selector(aboutButtonPressed(_:)), for: .touchUpInside)
        
        selectTab(with: activityButton)
    }
    
    private func selectTab(with button: Button) {
        switch button {
        case activityButton:
            activityButton.customizeAppearance(theme.activityButtonSelected)
            aboutButton.customizeAppearance(theme.aboutButton)
        case aboutButton:
            activityButton.customizeAppearance(theme.activityButton)
            aboutButton.customizeAppearance(theme.aboutButtonSelected)
        default:
            fatalError("Shouldn't enter here")
        }

        selectedMarkerView.removeFromSuperview()
        button.addSubview(selectedMarkerView)
        selectedMarkerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(theme.selectedMarkerHeight)
        }
    }
    
    @objc
    private func activityButtonPressed(_ sender: Button) {
        onActivityButtonPressed?()
        selectTab(with: sender)
    }
    
    @objc
    private func aboutButtonPressed(_ sender: Button) {
        onAboutButtonPressed?()
        selectTab(with: sender)
    }
    
}
