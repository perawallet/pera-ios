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
//   BannerErrorViewModel.swift

import Foundation
import Macaroon
import UIKit

struct BannerErrorViewModel: BannerViewModel {
    private(set) var icon: Image?
    private(set) var title: EditText?
    private(set) var message: EditText?

    init(
        _ someTitle: String,
        _ someMessage: String,
        _ someIcon: Image
    ) {
        bind(
            someTitle,
            someMessage,
            someIcon
        )
    }

    private mutating func bind(
        _ someTitle: String,
        _ someMessage: String,
        _ someIcon: Image
    ) {
        bindIcon(
            someIcon
        )
        bindTitle(
            someTitle
        )
        bindMessage(
            someMessage
        )
    }
}

extension BannerErrorViewModel {
    private mutating func bindIcon(
        _ someIcon: Image
    ) {
        icon = someIcon
    }

    private mutating func bindTitle(
        _ someTitle: String
    ) {
        title = someTitle.text
    }

    private mutating func bindMessage(
        _ someMessage: String
    ) {
        message = someMessage.text
    }
}
