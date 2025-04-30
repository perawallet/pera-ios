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

//   SessionCryptoTests.swift

import Testing

@testable import pera_staging

final class SessionCryptoTests {

    @Test("Generate entropy, mnemonic and seed and test the conversion methods")
    func entropyFromMnemonicMultipleTimes() throws {
        for _ in 0..<100 {
            try entropyFromMnemonic()
        }
    }
    
    private func entropyFromMnemonic() throws {
        
        let entropy1 = HDWalletUtils.generate256BitEntropy()
        let mnemonic1 = HDWalletUtils.generateMnemonic(fromEntropy: entropy1)
        assert(mnemonic1 != nil)
        let seed1 = HDWalletUtils.generateSeed(fromMnemonic: mnemonic1!)
        
        let entropy2 = HDWalletUtils.generateEntropy(fromMnemonic: mnemonic1!)
        assert(entropy1 == entropy2)
        
        let mnemonic2 = HDWalletUtils.generateMnemonic(fromEntropy: entropy2!)
        assert(mnemonic1 == mnemonic2)
        
        let seed2 = HDWalletUtils.generateSeed(fromMnemonic: mnemonic2!)
        assert(seed1 == seed2)
    }
}
