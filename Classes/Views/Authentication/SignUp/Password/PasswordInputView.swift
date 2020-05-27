//
//  PasswordInputView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class PasswordInputView: BaseView {
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 220.0, height: 20.0)
    }
    
    private(set) var passwordInputCircleViews = [PasswordInputCircleView]()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        return stackView
    }()
    
    override func configureAppearance() {
        backgroundColor = SharedColors.secondaryBackground
    }
    
    override func prepareLayout() {
        setupStackViewLayout()
        configureStackView()
    }
}

extension PasswordInputView {
    private func setupStackViewLayout() {
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func configureStackView() {
        for _ in 1...6 {
            let circleView = PasswordInputCircleView()
            passwordInputCircleViews.append(circleView)
            stackView.addArrangedSubview(circleView)
        }
    }
}
