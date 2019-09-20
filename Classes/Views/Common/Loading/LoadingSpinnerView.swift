//
//  LoadingSpinnerView.swift
//  algorand
//
//  Created by Göktuğ Berk Ulu on 19.09.2019.
//  Copyright © 2019 hippo. All rights reserved.
//

import UIKit
import Lottie

class LoadingSpinnerView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let viewSize = CGSize(width: 22.0, height: 22.0)
    }
    
    private let layout = Layout<LayoutConstants>()
    
    override var intrinsicContentSize: CGSize {
        return layout.current.viewSize
    }
    
    private lazy var loadingAnimationView: AnimationView = {
        let loadingAnimationView = AnimationView()
        loadingAnimationView.contentMode = .scaleAspectFit
        let animation = Animation.named("LoadingAnimation")
        loadingAnimationView.animation = animation
        return loadingAnimationView
    }()
    
    // MARK: Setup
    
    override func configureAppearance() {
        backgroundColor = .clear
    }
    
    override func prepareLayout() {
        addSubview(loadingAnimationView)
        
        loadingAnimationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: API

extension LoadingSpinnerView {
    func show() {
        loadingAnimationView.play(fromProgress: 0, toProgress: 1, loopMode: .loop)
    }
    
    func stop() {
        loadingAnimationView.stop()
    }
}
