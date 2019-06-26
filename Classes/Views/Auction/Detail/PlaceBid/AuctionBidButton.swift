//
//  AuctionBidButton.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 18.05.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit

class AuctionBidButton: UIButton {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let indicatorTrailingInset: CGFloat = 20.0
        let indicatorTopInset: CGFloat = 18.0
    }
    
    private let layout = Layout<LayoutConstants>()
    
    var buttonState: ButtonState = .normal {
        didSet {
            if buttonState == .loading {
                loadingIndicator.show()
            } else {
                loadingIndicator.dismiss()
            }
        }
    }
    
    // MARK: Components
    
    private(set) lazy var loadingIndicator: LoadingIndicator = {
        let loadingIndicator = LoadingIndicator()
        loadingIndicator.activityIndicator.color = SharedColors.purple
        return loadingIndicator
    }()
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureButton()
        setupLayout()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureButton() {
        setTitleColor(SharedColors.purple, for: .normal)
        setTitleColor(SharedColors.darkGray, for: .disabled)
        
        setBackgroundImage(img("bg-place-bid-button"), for: .normal)
        setBackgroundImage(img("bg-place-bid-button-disabled"), for: .disabled)
        
        titleLabel?.font = UIFont.font(.overpass, withWeight: .bold(size: 12.0))
    }
    
    private func setupLayout() {
        addSubview(loadingIndicator)
        
        loadingIndicator.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(layout.current.indicatorTopInset)
            make.trailing.equalToSuperview().inset(layout.current.indicatorTrailingInset)
        }
    }
}

enum ButtonState {
    case normal
    case loading
}
