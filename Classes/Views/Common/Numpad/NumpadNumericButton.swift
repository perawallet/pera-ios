//
//  NumpadButton.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.03.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class NumpadNumericButton: UIButton, NumpadTypeable {
    
    override var intrinsicContentSize: CGSize {
        return layout.current.size
    }
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let size = CGSize(width: 30.0, height: 36.0)
        let separatorWidth: CGFloat = 30.0
    }
    
    private enum Colors {
        static let buttonColor = rgba(0.04, 0.05, 0.07, 0.8)
        static let separatorColor = rgb(0.34, 0.34, 0.43)
    }
    
    private let layout = Layout<LayoutConstants>()
    
    var value: NumpadValue = .number(nil) {
        didSet {
            switch value {
            case .number(let number):
                if number == nil {
                    separatorImageView.isHidden = true
                    return
                }
                
                setTitle(number, for: .normal)
            default:
                break
            }
        }
    }
    
    var color: UIColor = Colors.buttonColor {
        didSet {
            setTitleColor(color, for: .normal)
            separatorImageView.tintColor = color
        }
    }
    
    // MARK: Components
    
    private lazy var separatorImageView = UIImageView(image: img("icon-numberpad-separator", isTemplate: true))
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isEnabled = false
        
        setTitleColor(color, for: .normal)
        separatorImageView.tintColor = Colors.separatorColor
        
        setupSeparatorImageViewLayout()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    private func setupSeparatorImageViewLayout() {
        addSubview(separatorImageView)
        
        separatorImageView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(layout.current.separatorWidth)
        }
    }
}
