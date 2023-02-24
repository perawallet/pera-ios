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

//   CollectibleFullScreenAudioViewController.swift

import AVFoundation
import Foundation
import MacaroonUIKit

final class CollectibleFullScreenAudioViewController: FullScreenContentViewController {
    private(set) lazy var audioPlayerView = AudioPlayerView()
        
    private var player: AVPlayer {
        return draft.player
    }
    
    private let draft: CollectibleFullScreenAudioDraft
    
    init(
        draft: CollectibleFullScreenAudioDraft,
        configuration: ViewControllerConfiguration
    ) {
        self.draft = draft
        super.init(configuration: configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addAudio()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
    }
    
    override func bindData() {
        super.bindData()
        audioPlayerView.player = player
    }
}

extension CollectibleFullScreenAudioViewController {
    private func addAudio() {
        audioPlayerView.clipsToBounds = true
        
        contentView.addSubview(audioPlayerView)
        audioPlayerView.snp.makeConstraints {
            $0.edges == 0
        }
    }
}
