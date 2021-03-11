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
//  Int16+Byte.swift

import Foundation

extension UInt16 {
    func shiftOneByteRight() -> UInt16 {
        return self >> 8
    }
    
    func shiftOneByteLeft() -> UInt16 {
        return self << 8
    }
    
    func removeExcessBytes() -> UInt16 {
        return self & 0xFF
    }
    
    var asByte: UInt8 {
        UInt8(self)
    }
}
