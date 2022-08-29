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

//   Cryptor.swift

import Foundation
import CommonCrypto
import CryptoSwift
import AlgoSDK

final class Cryptor {
    let key: String

    init(key: String) {
        self.key = key
    }

    func encrypt(data: Data) -> Data? {
        var encryptionError: NSError?
        let encryptedData = AlgoMobileEncrypt(data, generateKeyData(), &encryptionError)

        return encryptedData
    }

    func decrypt(data: Data) -> Data? {
        var decryptionError: NSError?
        let decryptedData = AlgoMobileDecrypt(data, generateKeyData(), &decryptionError)

        return decryptedData
    }

    private func generateKeyData() -> Data {
        let data = key.convertToByteArray(using: ",")

        return Data(bytes: data)
    }
}
