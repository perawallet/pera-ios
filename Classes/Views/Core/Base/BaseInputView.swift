//
//  BaseInputView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 21.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class BaseInputView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 25.0
        let contentViewTopInset: CGFloat = 7.0
        let separatorTopInset: CGFloat = 20.0
        let separatorInset: CGFloat = 15.0
        let separatorHeight: CGFloat = 1.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Customization
    
    var nextButtonMode = NextButtonMode.next
    
    private let displaysExplanationText: Bool
    private let displaysRightInputAccessoryButton: Bool
    private let separatorStyle: SeparatorStyle
    
    // MARK: Initialization
    
    init(displaysExplanationText: Bool = true, displaysRightInputAccessoryButton: Bool = false, separatorStyle: SeparatorStyle = .full) {
        self.displaysExplanationText = displaysExplanationText
        self.displaysRightInputAccessoryButton = displaysRightInputAccessoryButton
        self.separatorStyle = separatorStyle
        
        super.init(frame: .zero)
    }
    
    // MARK: Components
    
    private(set) lazy var explanationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = rgb(0.67, 0.67, 0.72)
        return label
    }()
    
    private(set) lazy var contentView = UIView()
    
    private(set) lazy var rightInputAccessoryButton = UIButton(type: .custom)
    
    private(set) lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = rgba(0.67, 0.67, 0.72, 0.31)
        return view
    }()
    
    weak var delegate: InputViewDelegate?
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupExplanationLabelLayout()
        setupRightInputAccessoryButtonLayout()
        setupContentViewLayout()
        setupSeparatorViewLayout()
    }
    
    private func setupExplanationLabelLayout() {
        if !displaysExplanationText {
            return
        }
        
        addSubview(explanationLabel)
        
        explanationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.defaultInset)
            make.top.equalToSuperview()
        }
    }
    
    private func setupRightInputAccessoryButtonLayout() {
        if !displaysRightInputAccessoryButton {
            return
        }
        
        addSubview(rightInputAccessoryButton)
        
        rightInputAccessoryButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.separatorInset)
            
            if displaysExplanationText {
                make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.contentViewTopInset)
            } else {
                make.top.equalToSuperview()
            }
        }
    }
    
    private func setupContentViewLayout() {
        addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            
            if displaysRightInputAccessoryButton {
                make.trailing.equalTo(rightInputAccessoryButton.snp.leading).inset(layout.current.defaultInset)
            } else {
                make.trailing.equalToSuperview().inset(layout.current.defaultInset)
            }
            
            if displaysExplanationText {
                make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.contentViewTopInset)
            } else {
                make.top.equalToSuperview()
            }
        }
    }
    
    private func setupSeparatorViewLayout() {
        if separatorStyle == .none {
            return
        }
        
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.top.equalTo(contentView.snp.bottom).offset(layout.current.separatorTopInset)
            
            if separatorStyle == .full {
                make.leading.trailing.equalToSuperview()
            } else {
                make.leading.trailing.equalToSuperview().inset(layout.current.separatorInset)
            }
        }
    }
}

// MARK: NextButtonMode

extension BaseInputView {
    
    enum NextButtonMode {
        case next
        case submit
    }
}

// MARK: SeparatorStyle

extension BaseInputView {
    
    enum SeparatorStyle {
        case none
        case colored
        case full
    }
}
