// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   CollectibleMediaAudioPreviewView.swift

import AVFoundation
import MacaroonUIKit
import MacaroonURLImage
import UIKit

final class CollectibleMediaAudioPreviewView:
    View,
    ViewModelBindable,
    ListReusable,
    UIInteractable {
    private(set) var uiInteractions: [Event : MacaroonUIKit.UIInteraction] = [
        .perform3DModeAction: TargetActionInteraction(),
        .performFullScreenAction: TargetActionInteraction()
    ]
    
    private lazy var placeholderView = URLImagePlaceholderView()
    private(set) lazy var audioPlayerView = AudioPlayerView()
    private lazy var overlayView = UIImageView()
    private lazy var threeDModeActionView = MacaroonUIKit.Button(.imageAtLeft(spacing: 8))
    private lazy var fullScreenActionView = MacaroonUIKit.Button()
    
    var currentPlayer: AVPlayer? {
        return audioPlayerView.player
    }
    
    func customize(_ theme: CollectibleMediaAudioPreviewViewTheme) {
        addPlaceholderView(theme)
        addAudioPlayerView(theme)
        addOverlayView(theme)
        add3DModeAction(theme)
        addFullScreenAction(theme)
    }
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    deinit {
        removeObservers()
    }
}

extension CollectibleMediaAudioPreviewView {
    private func addPlaceholderView(_ theme: CollectibleMediaAudioPreviewViewTheme) {
        placeholderView.build(theme.placeholder)
        placeholderView.layer.draw(corner: theme.corner)
        placeholderView.clipsToBounds = true
        
        addSubview(placeholderView)
        placeholderView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
    
    private func addAudioPlayerView(_ theme: CollectibleMediaAudioPreviewViewTheme) {
        audioPlayerView.layer.draw(corner: theme.corner)
        audioPlayerView.clipsToBounds = true
        
        addSubview(audioPlayerView)
        audioPlayerView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
    
    private func addOverlayView(_ theme: CollectibleMediaAudioPreviewViewTheme) {
        addSubview(overlayView)
        overlayView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
    
    private func add3DModeAction(_ theme: CollectibleMediaAudioPreviewViewTheme) {
        threeDModeActionView.customizeAppearance(theme.threeDAction)
        
        addSubview(threeDModeActionView)
        threeDModeActionView.contentEdgeInsets = UIEdgeInsets(theme.threeDActionContentEdgeInsets)
        threeDModeActionView.snp.makeConstraints {
            $0.leading == theme.threeDActionPaddings.leading
            $0.bottom == theme.threeDActionPaddings.bottom
        }
        
        startPublishing(
            event: .perform3DModeAction,
            for: threeDModeActionView
        )
    }
    
    private func addFullScreenAction(_ theme: CollectibleMediaAudioPreviewViewTheme) {
        fullScreenActionView.customizeAppearance(theme.fullScreenAction)
        
        addSubview(fullScreenActionView)
        fullScreenActionView.snp.makeConstraints {
            $0.trailing == theme.fullScreenBadgePaddings.trailing
            $0.bottom == theme.fullScreenBadgePaddings.bottom
        }
        
        startPublishing(
            event: .performFullScreenAction,
            for: fullScreenActionView
        )
    }
}

extension CollectibleMediaAudioPreviewView {
    func bindData(_ viewModel: CollectibleMediaAudioPreviewViewModel?) {
        placeholderView.placeholder = viewModel?.placeholder
        
        guard let viewModel,
              let url = viewModel.url else {
            prepareForReuse()
            return
        }
        
        let audioPlayer = AVPlayer(url: url)
        audioPlayer.playImmediately(atRate: 1)
        audioPlayerView.player = audioPlayer
        
        addObservers()
        
        overlayView.image = viewModel.overlayImage
        threeDModeActionView.isHidden = viewModel.is3DModeActionHidden
        fullScreenActionView.isHidden = viewModel.isFullScreenActionHidden
    }
    
    class func calculatePreferredSize(
        _ viewModel: CollectibleMediaAudioPreviewViewModel?,
        for layoutSheet: CollectibleMediaAudioPreviewViewTheme,
        fittingIn size: CGSize
    ) -> CGSize {
        return CGSize((size.width, size.height))
    }
}

extension CollectibleMediaAudioPreviewView {
    func prepareForReuse() {
        removeObservers()
        stopAudio()
        audioPlayerView.player = nil
        placeholderView.prepareForReuse()
        overlayView.image = nil
        threeDModeActionView.isHidden = false
        fullScreenActionView.isHidden = false
    }
}

extension CollectibleMediaAudioPreviewView {
    @objc
    private func playerItemDidReachEnd() {
        audioPlayerView.player?.seek(to: .zero)
        audioPlayerView.player?.play()
    }
}

extension CollectibleMediaAudioPreviewView {
    func playAudio() {
        audioPlayerView.player?.play()
    }

    func stopAudio() {
        audioPlayerView.player?.pause()
    }
}

extension CollectibleMediaAudioPreviewView {
    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: audioPlayerView.player?.currentItem
        )
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
}

extension CollectibleMediaAudioPreviewView {
    enum Event {
        case performFullScreenAction
        case perform3DModeAction
    }
}
