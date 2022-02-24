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

//   MoonpayIntroductionViewController.swift

import MacaroonUIKit
import UIKit

final class MoonpayIntroductionViewController: BaseViewController {
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    private lazy var moonpayIntroductionView = MoonpayIntroductionView()
    
    override func prepareLayout() {
        super.prepareLayout()
        addMoonpayIntroductionView()
    }
    
    override func setListeners() {
        super.setListeners()
        
        moonpayIntroductionView.observe(event: .closeScreen) {
            [weak self] in
            guard let self = self else { return }
            self.dismissScreen()
        }
        
        moonpayIntroductionView.observe(event: .buyAlgo) {}
    }
}

extension MoonpayIntroductionViewController {
    private func addMoonpayIntroductionView() {
        moonpayIntroductionView.customize(MoonpayIntroductionViewTheme())
        moonpayIntroductionView.bindData(MoonpayIntroductionViewModel())
        
        view.addSubview(moonpayIntroductionView)
        moonpayIntroductionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
