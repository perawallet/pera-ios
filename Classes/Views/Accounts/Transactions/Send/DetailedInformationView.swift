//
//  DetailedInformationView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 10.04.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class DetailedInformationView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultInset: CGFloat = 25.0
        let verticalInset: CGFloat = 20.0
        let contentViewTopInset: CGFloat = 7.0
        let amountViewHeight: CGFloat = 16.0
        let separatorTopInset: CGFloat = 20.0
        let buttonTopInset: CGFloat = 7.0
        let separatorHeight: CGFloat = 1.0
        let buttonWidth: CGFloat = 20.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let separatorColor = rgba(0.67, 0.67, 0.72, 0.31)
    }
    
    // MARK: Components
    
    private(set) lazy var explanationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(.opensans, withWeight: .semiBold(size: 12.0))
        label.textColor = SharedColors.softGray
        return label
    }()
    
    private(set) lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(.montserrat, withWeight: .semiBold(size: 13.0))
        label.textColor = SharedColors.black
        return label
    }()
    
    private(set) lazy var algosAmountView: AlgosAmountView = {
        let view = AlgosAmountView()
        view.amountLabel.textAlignment = .left
        view.algoIconImageView.image = img("icon-algo-min")
        view.amountLabel.font = UIFont.font(.montserrat, withWeight: .bold(size: 13.0))
        view.mode = .normal(0.0)
        return view
    }()
    
    private(set) lazy var rightInputAccessoryButton = UIButton(type: .custom)
    
    private(set) lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.separatorColor
        return view
    }()
    
    private let mode: Mode
    private let displaysRightInputAccessoryButton: Bool
    
    // MARK: Initialization
    
    init(mode: Mode = .text, displaysRightInputAccessoryButton: Bool = false) {
        self.mode = mode
        self.displaysRightInputAccessoryButton = displaysRightInputAccessoryButton
        
        super.init(frame: .zero)
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupExplanationLabelLayout()
        setupRightInputAccessoryButtonLayout()
        
        if mode == .text {
            setupDetailLabelLayout()
        } else {
            setupAlgosAmountViewLayout()
        }
        
        setupSeparatorViewLayout()
    }
    
    private func setupExplanationLabelLayout() {
        addSubview(explanationLabel)
        
        explanationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.defaultInset)
            make.top.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupRightInputAccessoryButtonLayout() {
        addSubview(rightInputAccessoryButton)
        
        rightInputAccessoryButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.buttonTopInset)
            make.width.equalTo(layout.current.buttonWidth)
        }
    }
    
    private func setupDetailLabelLayout() {
        addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.contentViewTopInset)
            
            if displaysRightInputAccessoryButton {
                make.trailing.equalTo(rightInputAccessoryButton.snp.leading).inset(-layout.current.defaultInset)
            } else {
                make.trailing.equalToSuperview().inset(layout.current.defaultInset)
            }
        }
    }
    
    private func setupAlgosAmountViewLayout() {
        addSubview(algosAmountView)
        
        algosAmountView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.defaultInset)
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.contentViewTopInset)
            make.height.equalTo(layout.current.amountViewHeight)
            
            if displaysRightInputAccessoryButton {
                make.trailing.lessThanOrEqualTo(rightInputAccessoryButton.snp.leading).inset(-layout.current.defaultInset)
            } else {
                make.trailing.lessThanOrEqualToSuperview().inset(layout.current.defaultInset)
            }
        }
    }
    
    private func setupSeparatorViewLayout() {
        addSubview(separatorView)
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(layout.current.separatorHeight)
            make.leading.trailing.equalToSuperview()
            
            if mode == .text {
                make.top.equalTo(detailLabel.snp.bottom).offset(layout.current.separatorTopInset)
            } else {
                make.top.equalTo(algosAmountView.snp.bottom).offset(layout.current.separatorTopInset)
            }
        }
    }
    
}

// MARK: Mode

extension DetailedInformationView {
    
    enum Mode {
        case text
        case algos
    }
}
