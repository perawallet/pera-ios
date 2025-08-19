// Copyright 2022-2025 Pera Wallet, LDA

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
//  Int.swift

import Foundation

public let algosInMicroAlgos = 1000000
public let minimumFee: UInt64 = 1000
public let totalNumIntConstantForMinimumAmount: UInt64 = 28500
public let byteSliceConstantForMinimumAmount: UInt64 = 50000
public let minimumTransactionMicroAlgosLimit: UInt64 = 100000
public let algosFraction = 6
public let dataSizeForMaxTransaction: UInt64 = 270

public extension Int {
    func convertSecondsToHoursMinutesSeconds() -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        return formatter.string(from: TimeInterval(self))
    }
}

public extension UInt64 {
    var toAlgos: Decimal {
        Decimal(self) / Decimal(algosInMicroAlgos)
    }
    
    var isNegative: Bool {
        self < 0
    }

    func assetAmount(fromFraction decimal: Int) -> Decimal {
        if decimal == 0 {
            return Decimal(self)
        }
        return Decimal(self) / pow(10, decimal)
    }
    
    func rotateLeft(_ times: UInt64) -> UInt64 {
      (self << times) | (self >> (64 - times))
    }

    func rotateRight(_ times: UInt64) -> UInt64 {
      (self >> times) | (self << (64 - times))
    }

    func reverseBytes() -> UInt64 {
      let tmp1 = ((self & 0x0000_0000_0000_00FF) << 56) |
        ((self & 0x0000_0000_0000_FF00) << 40) |
        ((self & 0x0000_0000_00FF_0000) << 24) |
        ((self & 0x0000_0000_FF00_0000) << 8)

      let tmp2 = ((self & 0x0000_00FF_0000_0000) >> 8) |
        ((self & 0x0000_FF00_0000_0000) >> 24) |
        ((self & 0x00FF_0000_0000_0000) >> 40) |
        ((self & 0xFF00_0000_0000_0000) >> 56)

      return tmp1 | tmp2
    }
}
