// Copyright 2019 Algorand, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//   HomeLoadingView.swift

import Foundation
import MacaroonUIKit
import UIKit

final class HomeLoadingView:
    View,
    ListReusable {
    private lazy var loadingView = LoadingView()
    
    override init(
        frame: CGRect
    ) {
        super.init(frame: frame)
        addLoading()
    }
    
    func customizeAppearance(
        _ styleSheet: NoStyleSheet
    ) {}

    func prepareLayout(
        _ layoutSheet: NoLayoutSheet
    ) {}
}

extension HomeLoadingView {
    func startAnimating() {
        loadingView.startAnimating()
    }
    
    func stopAnimating() {
        loadingView.stopAnimating()
    }
}

extension HomeLoadingView {
    private func addLoading() {
        loadingView.customize(LoadingViewCommonTheme())
        
        addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
}
