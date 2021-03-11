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
//  RoundDetail.swift

import Magpie

class RoundDetail: Model {
    let lastRound: Int64
    let nextVersionRound: Int64
}

extension RoundDetail {
    private enum CodingKeys: String, CodingKey {
        case lastRound = "last-round"
        case nextVersionRound = "next-version-round"
    }
}
