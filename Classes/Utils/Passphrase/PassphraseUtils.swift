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

//   PassphraseUtils.swift

enum PassphraseUtils {
    
    struct MnemonicsData {
        let mnemonics: [String]
        let isHDWallet: Bool
    }
    
    // MARK: - Actions
    
    static func isHDWallet(account: Account, hdWalletStorage: HDWalletStorable) -> Bool {
        guard let hdWalletID = account.hdWalletAddressDetail?.walletId else { return false }
        return (try? hdWalletStorage.wallet(id: hdWalletID)) != nil
    }
    
    static func mnemonics(account: Account, hdWalletStorage: HDWalletStorable, session: Session) -> MnemonicsData {
        
        guard let hdWalletID = account.hdWalletAddressDetail?.walletId, let hdWallet = try? hdWalletStorage.wallet(id: hdWalletID) else {
            let mnemonics = session.mnemonics(forAccount: account.address)
            return MnemonicsData(mnemonics: mnemonics, isHDWallet: false)
        }
        
        let mnemonics = HDWalletUtils.generateMnemonic(fromEntropy: hdWallet.entropy)?.components(separatedBy: .whitespaces) ?? []
        return MnemonicsData(mnemonics: mnemonics, isHDWallet: true)
    }
}

extension PassphraseUtils.MnemonicsData {
    static let empty: Self = Self(mnemonics: [], isHDWallet: false)
}
