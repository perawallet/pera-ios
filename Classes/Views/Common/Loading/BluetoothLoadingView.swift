//
//  BluetoothLoadingView.swift
//  algorand
//
//  Created by Omer Emre Aslan on 30.03.2020.
//  Copyright © 2020 hippo. All rights reserved.
//

import UIKit
import Lottie

class BluetoothLoadingView: BaseView {
    
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let viewSize = CGSize(width: 100.0, height: 100.0)
    }
    
    private let layout = Layout<LayoutConstants>()
    
    override var intrinsicContentSize: CGSize {
        return layout.current.viewSize
    }
    
    private lazy var loadingAnimationView: AnimationView = {
        let loadingAnimationView = AnimationView()
        loadingAnimationView.contentMode = .scaleAspectFit
        let animation = Animation.named("bluetooth_animation")
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

extension BluetoothLoadingView {
    func show() {
        loadingAnimationView.play(fromProgress: 0, toProgress: 1, loopMode: .loop)
    }
    
    func stop() {
        loadingAnimationView.stop()
    }
}
