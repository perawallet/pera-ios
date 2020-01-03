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
        let defaultInset: CGFloat = 15.0
        let labelInset: CGFloat = 30.0
        let contentViewTopInset: CGFloat = 7.0
        let contentViewMaximumTopInset: CGFloat = 10.0
        let buttonTopInset: CGFloat = 11.0
        let buttonTrailingInset: CGFloat = 13.0
        let buttonWidth: CGFloat = 36.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let borderColor = rgb(0.94, 0.94, 0.94)
    }
    
    // MARK: Customization
    
    var nextButtonMode = NextButtonMode.next
    
    private let displaysExplanationText: Bool
    let displaysRightInputAccessoryButton: Bool
    
    // MARK: Components
    
    private(set) lazy var explanationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(.avenir, withWeight: .medium(size: 13.0))
        label.textColor = SharedColors.greenishGray
        return label
    }()
    
    private(set) lazy var contentView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1.0
        view.layer.borderColor = Colors.borderColor.cgColor
        view.layer.cornerRadius = 4.0
        view.backgroundColor = .white
        return view
    }()
    
    private(set) lazy var rightInputAccessoryButton = UIButton(type: .custom)
    
    weak var delegate: InputViewDelegate?
    
    // MARK: Initialization
    
    init(displaysExplanationText: Bool = true, displaysRightInputAccessoryButton: Bool = false) {
        self.displaysExplanationText = displaysExplanationText
        self.displaysRightInputAccessoryButton = displaysRightInputAccessoryButton
        super.init(frame: .zero)
    }
    
    override func linkInteractors() {
        rightInputAccessoryButton.addTarget(self, action: #selector(notifyDelegateToAccessoryButtonTapped), for: .touchUpInside)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupExplanationLabelLayout()
        setupContentViewLayout()
        setupRightInputAccessoryButtonLayout()
    }
    
    private func setupExplanationLabelLayout() {
        if !displaysExplanationText {
            return
        }
        
        addSubview(explanationLabel)
        
        explanationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.labelInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.labelInset)
            make.top.equalToSuperview()
        }
    }
    
    private func setupContentViewLayout() {
        addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.bottom.equalToSuperview()
            
            if displaysExplanationText {
                make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.contentViewTopInset)
            } else {
                make.top.equalToSuperview().offset(layout.current.contentViewMaximumTopInset)
            }
        }
    }
    
    private func setupRightInputAccessoryButtonLayout() {
        if !displaysRightInputAccessoryButton {
            return
        }
        
        contentView.addSubview(rightInputAccessoryButton)
        
        rightInputAccessoryButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.buttonTrailingInset)
            make.top.equalToSuperview().inset(layout.current.buttonTopInset)
            make.width.height.equalTo(layout.current.buttonWidth)
        }
    }
    
    // MARK: Actions
    
    @objc
    func notifyDelegateToAccessoryButtonTapped() {
        delegate?.inputViewDidTapAccessoryButton(inputView: self)
    }
}

// MARK: NextButtonMode

extension BaseInputView {
    enum NextButtonMode {
        case next
        case submit
    }
}
