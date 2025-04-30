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

//   HDWalletUtils.swift

import Foundation
import MnemonicSwift

public struct HDWalletUtils {
    
    // Generate mnemonic (24 word) for an entropy (256 bit)
    public static func generateMnemonic(fromEntropy entropy: Data) -> String? {
        do {
            let mnemonic = try Mnemonic.mnemonicString(from: entropy.toHexString())
            try Mnemonic.validate(mnemonic: mnemonic)
            return mnemonic
        } catch {
            assertionFailure("Failed to generate mnemonic: \(error)")
            return nil
        }
    }
    
    // Generate seed for a mnemonic (24 word)
    public static func generateSeed(fromMnemonic mnemonic: String) -> Data? {
        do {
            let deterministicSeedString = try Mnemonic.deterministicSeedString(from: mnemonic)
            guard let seed = Data(fromHexEncodedString: deterministicSeedString) else {
                throw MnemonicsError.missingWords
            }
            return seed
        } catch {
            assertionFailure("Failed to generate seed: \(error)")
            return nil
        }
    }
    
    // Generate seed for an entropy (256 bit)
    public static func generateSeed(fromEntropy entropy: Data) -> Data? {
        guard let mnemonic = generateMnemonic(fromEntropy: entropy) else {
            assertionFailure("Failed to generate mnemonic")
            return nil
        }
        return generateSeed(fromMnemonic: mnemonic)
    }
    
    // Generate entropy (256 bit) for a mnemonic (24 word)
    public static func generateEntropy(fromMnemonic mnemonic: String) -> Data? {
        guard let binaryString = convertMnemonicToBinary(mnemonic: mnemonic) else {
            assertionFailure("Failed to generate binaryString")
            return nil
        }
        return extractEntropy(fromBinaryString: binaryString)
    }
    
    // Convert mnemonic to binary representation
    private static func convertMnemonicToBinary(mnemonic: String) -> String? {
        let words = mnemonic.components(separatedBy: .whitespaces)
        var binaryString = ""

        for word in words {
            if let index = index(of: String(word)) {
                // Convert the index to binary, pad with leading zeros to 11 bits
                let binary = String(index, radix: 2).padLeft(toLength: 11, withPad: "0")
                binaryString += binary
            } else {
                return nil // Invalid word in mnemonic
            }
        }
        return binaryString
    }
    
    // Retrives the index of a mnemonic word in the bip 39 word list
    private static func index(of word: String, in wordlist: [String] = String.englishMnemonics) -> Int? {
        return wordlist.firstIndex(of: word)
    }
    
    // Extracts the 256-bit entropy from a binary string and validates the checksum. Returns the entropy data if valid, or nil if the checksum is incorrect.
    private static func extractEntropy(fromBinaryString binaryString: String, includeChecksum: Bool = false) -> Data? {
        let checksumLength = 8 // Checksum is always 8 bits
        let entropyLength = binaryString.count - checksumLength
        
        assert(entropyLength == 256, "Entropy length must be 256 bits")
        
        let entropyBinary = binaryString.prefix(entropyLength)
        let checksumBinary = binaryString.suffix(checksumLength)

        // Calculate the checksum from the entropy to verify it
        guard let entropyData = data(fromBinaryString: String(entropyBinary)) else {
            assertionFailure("Failed to convert entropy binary to data")
          return nil
        }

        let calculatedChecksum = calculateChecksum(for: entropyData)
        
        // Compare calculated checksum with the extracted checksum
        guard checksumBinary == calculatedChecksum else { return nil }

        return entropyData
    }
    
    // Converts a binary string into a Data object by grouping it into 8-bit chunks. Returns nil if the binary string is invalid.
    private static func data(fromBinaryString binaryString: String) -> Data? {
        var data = Data()
        
        for i in stride(from: 0, to: binaryString.count, by: 8) {
            let byteString = String(binaryString[binaryString.index(binaryString.startIndex, offsetBy: i)..<binaryString.index(binaryString.startIndex, offsetBy: min(i + 8, binaryString.count))])
            
            if let byte = UInt8(byteString, radix: 2) {
                data.append(byte)
            } else {
                return nil // Invalid binary
            }
        }
        
        return data
    }
    
    // Calculates the checksum for the given data by computing its SHA-256 hash and returning the first 8 bits as a binary string.
    private static func calculateChecksum(for data: Data) -> String {
        let hash = data.sha256() // Compute SHA-256 hash
        let hashBinaryString = hash.toBinaryString() // Convert hash to binary string
        let checksumBits = String(hashBinaryString.prefix(8)) // First 8 bits for 256-bit entropy
        return checksumBits
    }
    
    // Generate 256 bits (32 bytes) of entropy
    public static func generate256BitEntropy() -> Data {
        var entropyBytes = [UInt8](repeating: 0, count: 32)
        let status = SecRandomCopyBytes(kSecRandomDefault, entropyBytes.count, &entropyBytes)
        guard status == errSecSuccess else { fatalError("Entropy generation failed") }

        return Data(entropyBytes)
    }
}
