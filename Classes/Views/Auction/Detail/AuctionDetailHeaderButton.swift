//
//  AuctionDetailHeaderButton.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AuctionDetailHeaderButton: UIButton {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let labelSize = CGSize(width: 26.0, height: 26.0)
        let labelTopInset: CGFloat = -6.0
        let labelTrailingOffset: CGFloat = 6.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    // MARK: Components
    
    private(set) lazy var cornerLabel: UILabel = {
        let label = UILabel()
            .withAlignment(.center)
            .withLine(.single)
            .withTextColor(.white)
            .withFont(UIFont.font(.overpass, withWeight: .bold(size: 12.0)))
        label.backgroundColor = SharedColors.purple
        label.isHidden = true
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 13.0
        return label
    }()
    
    private var hasCornerLabel: Bool
    
    // MARK: Initialization
    
    init(hasCornerLabel: Bool = false) {
        self.hasCornerLabel = hasCornerLabel
        
        super.init(frame: .zero)
        
        configureButton()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureButton() {
        setTitleColor(SharedColors.black, for: .normal)
        setTitleColor(.white, for: .selected)
        
        setBackgroundImage(img("bg-bid-button"), for: .normal)
        setBackgroundImage(img("bg-bid-button-selected"), for: .selected)
        
        titleLabel?.font = UIFont.font(.overpass, withWeight: .semiBold(size: 14.0))
        
        if hasCornerLabel {
            setupCornerLabelLayout()
        }
    }
    
    private func setupCornerLabelLayout() {
        addSubview(cornerLabel)
        
        cornerLabel.snp.makeConstraints { make in
            make.size.equalTo(layout.current.labelSize)
            make.top.equalToSuperview().inset(layout.current.labelTopInset)
            make.trailing.equalToSuperview().offset(layout.current.labelTrailingOffset)
        }
    }
}
