// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   PeraIntroductionViewController.swift

import MacaroonUIKit
import UIKit

final class PeraIntroductionViewController: BaseViewController {
    override var shouldShowNavigationBar: Bool {
        return false
    }

    private lazy var peraIntroductionView = PeraIntroductionView()

    override func prepareLayout() {
        super.prepareLayout()
        addPeraIntroductionView()
    }

    override func setListeners() {
        super.setListeners()

        peraIntroductionView.observe(event: .closeScreen) {
            [weak self] in
            guard let self = self else { return }
            self.dismissScreen()
        }

        peraIntroductionView.delegate = self
    }
}

extension PeraIntroductionViewController {
    private func addPeraIntroductionView() {
        view.addSubview(peraIntroductionView)
        peraIntroductionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension PeraIntroductionViewController: PeraIntroductionViewDelegate {
    func peraInroductionViewDidTapPeraWalletBlog(_ peraIntroductionView: PeraIntroductionView) {
        open(AlgorandWeb.peraBlogLaunchAnnouncement.link)
    }
}

struct PeraIntroductionStore: Storable {
    typealias Object = Any

    private let firstPeraLaunch = "com.algorand.first.pera.launch"

    var isFirstPeraLaunch: Bool {
        return !userDefaults.bool(forKey: firstPeraLaunch)
    }

    func saveFirstLaunchPera() {
        userDefaults.set(true, forKey: firstPeraLaunch)
    }
}
