// Copyright 2025 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   AddressWealthBalanceChartDataDraft.swift

import MagpieCore

struct AddressWealthBalanceChartDataDraft: ObjectQuery {
    var period: ChartDataPeriod
    var currency: String
    var ordering: String?
    
    var queryParams: [APIQueryParam] {
        var params: [APIQueryParam] = []

        params.append(APIQueryParam(.period, period.rawValue))
        params.append(APIQueryParam(.currency, currency))
        
        if let ordering {
            params.append(APIQueryParam(.ordering, ordering))
        }

        return params
    }
}
