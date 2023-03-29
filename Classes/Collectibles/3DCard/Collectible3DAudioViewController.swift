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

//   Collectible3DAudioViewController.swift

import AVFoundation
import Foundation
import MacaroonUIKit
import MacaroonUtils
import SceneKit

final class Collectible3DAudioViewController:
    BaseViewController,
    Collectible3DCardDisplayable {
    typealias EventHandler = (Event) -> Void
    var eventHandler: EventHandler?
    
    var sceneMaterial: SCNMaterial?
    var sceneView: SCNView?
    
    let renderContext = CIContext(
        options: [.useSoftwareRenderer: false]
    )

    private lazy var theme = Collectible3DViewerTheme()
    private lazy var closeButton = UIButton(type: .custom)

    private var audioPlayer: AVPlayer?

    private let image: UIImage?
    private let url: URL

    init(
        image: UIImage?,
        url: URL,
        configuration: ViewControllerConfiguration
    ) {
        self.image = image
        self.url = url
        
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        add3DAudioCard()
    }

    override func setListeners() {
        super.setListeners()
        closeButton.addTarget(
            self,
            action: #selector(didTapCloseButton),
            for: .touchUpInside
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
}

extension Collectible3DAudioViewController {
    private func add3DAudioCard() {
        sceneView = composeSceneView(on: view)
        sceneMaterial = composeSceneMaterial()
        
        let aView = view
        
        DispatchQueue.global(qos: .userInitiated).async {
            [weak self] in
            guard let self,
                  let aView else {
                return
            }
            
            if let image = self.image,
               let scaledImage = image.resized(
                CGSize(
                    width: image.size.width * 3,
                    height: image.size.height * 3
                ),
                .aspectFit
            ) {
                self.setupBlurredBackground(
                    from: scaledImage,
                    to: aView
                )
            } else {
                asyncMain {
                    [weak self] in
                    guard let self else { return }
                    
                    self.view.backgroundColor = Colors.Defaults.background.uiColor
                }
            }
            
            self.addSceneView()
        }
    }
    
    private func addSceneView() {
        setupScene(for: image?.size ?? .zero)
        
        asyncMain {
            [weak self] in
            guard let self else { return }
            
            if let sceneView = self.sceneView {
                self.view.addSubview(sceneView)
            }
            
            self.addCloseButton()
            self.setupAudioPlayer()
            self.animateGroupNode()
            self.audioPlayer?.play()
        }
    }
    
    private func setupAudioPlayer() {
        let audioPlayer = AVPlayer(url: url)
        audioPlayer.actionAtItemEnd = .none
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: audioPlayer.currentItem
        )
        
        self.audioPlayer = audioPlayer
        sceneView?.rendersContinuously = true
        sceneMaterial?.diffuse.contents = audioPlayer
    }
    
    private func addCloseButton() {
        closeButton.customizeAppearance(theme.close)
        
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.leading == theme.buttonLeadingPadding
            $0.top == theme.buttonTopPadding
            $0.fitToSize(theme.butonSize)
        }
    }
}

extension Collectible3DAudioViewController {
    @objc
    private func playerItemDidReachEnd() {
        audioPlayer?.seek(to: CMTime.zero)
    }
}

extension Collectible3DAudioViewController {
    @objc
    private func didTapCloseButton() {
        eventHandler?(.didClose)
    }
}

extension Collectible3DAudioViewController {
    enum Event {
        case didClose
    }
}
