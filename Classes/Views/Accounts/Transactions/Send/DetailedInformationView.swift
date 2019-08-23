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
        let horizontalInset: CGFloat = 15.0
        let labelLeadingInset: CGFloat = 30.0
        let labelTopInset: CGFloat = 15.0
        let containerViewTopInset: CGFloat = 7.0
        let verticalInset: CGFloat = 16.0
        let amountViewHeight: CGFloat = 22.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    private enum Colors {
        static let borderColor = rgb(0.94, 0.94, 0.94)
    }
    
    // MARK: Components
    
    private(set) lazy var explanationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.font(.avenir, withWeight: .medium(size: 13.0))
        label.textColor = SharedColors.gray
        return label
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1.0
        view.layer.borderColor = Colors.borderColor.cgColor
        view.layer.cornerRadius = 4.0
        view.backgroundColor = .white
        return view
    }()
    
    private(set) lazy var detailLabel: UILabel = {
        UILabel()
            .withFont(UIFont.font(.overpass, withWeight: .semiBold(size: 13.0)))
            .withTextColor(SharedColors.black)
            .withLine(.contained)
    }()
    
    private(set) lazy var algosAmountView: AlgosAmountView = {
        let view = AlgosAmountView()
        view.amountLabel.textAlignment = .left
        view.algoIconImageView.image = img("icon-algo-min")
        view.amountLabel.font = UIFont.font(.overpass, withWeight: .bold(size: 15.0))
        view.mode = .normal(0.0)
        return view
    }()
    
    private let mode: Mode
    
    // MARK: Initialization
    
    init(mode: Mode = .text) {
        self.mode = mode
        
        super.init(frame: .zero)
    }
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    // MARK: Layout
    
    override func prepareLayout() {
        setupExplanationLabelLayout()
        setupContainerViewLayout()
        if mode == .text {
            setupDetailLabelLayout()
        } else {
            setupAlgosAmountViewLayout()
        }
    }
    
    private func setupExplanationLabelLayout() {
        addSubview(explanationLabel)
        
        explanationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.labelLeadingInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.labelTopInset)
        }
    }
    
    private func setupContainerViewLayout() {
        addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.bottom.equalToSuperview()
            make.top.equalTo(explanationLabel.snp.bottom).offset(layout.current.containerViewTopInset)
        }
    }
    
    private func setupDetailLabelLayout() {
        containerView.addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.verticalInset)
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
        }
    }
    
    private func setupAlgosAmountViewLayout() {
        containerView.addSubview(algosAmountView)
        
        algosAmountView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(layout.current.horizontalInset)
            make.trailing.lessThanOrEqualToSuperview().inset(layout.current.horizontalInset)
            make.top.equalToSuperview().inset(layout.current.verticalInset)
            make.bottom.equalToSuperview().inset(layout.current.verticalInset)
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
