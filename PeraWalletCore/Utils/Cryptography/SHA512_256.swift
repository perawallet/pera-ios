// Modified off of Matan Lachmish's Cryptography repo
// https://github.com/mlachmish/Cryptography/ MIT License
//
// SHA2 [.] swift
//  Cryptography
//
//  Created by Matan Lachmish on 25/07/2016.
//  Copyright © 2016 The Big Fat Ninja. All rights reserved.

import Foundation

// MARK: - SHA512_256

struct SHA512_256 {
  func hash(_ message: [UInt8]) -> [UInt8] {
    SHA2.hash64Bit(message: message)
  }
}

public let blockSize: Int = 128

let h: [UInt64] = [0x2231_2194_FC2B_F72C, 0x9F55_5FA3_C84C_64C2, 0x2393_B86B_6F53_B151, 0x9638_7719_5940_EABD,
                   0x9628_3EE2_A88E_FFE3, 0xBE5E_1E25_5386_3992, 0x2B01_99FC_2C85_B8AA, 0x0EB7_2DDC_81C5_2CA2]

let k: [UInt64] = [
  0x428A_2F98_D728_AE22,
  0x7137_4491_23EF_65CD,
  0xB5C0_FBCF_EC4D_3B2F,
  0xE9B5_DBA5_8189_DBBC,
  0x3956_C25B_F348_B538,
  0x59F1_11F1_B605_D019,
  0x923F_82A4_AF19_4F9B,
  0xAB1C_5ED5_DA6D_8118,
  0xD807_AA98_A303_0242,
  0x1283_5B01_4570_6FBE,
  0x2431_85BE_4EE4_B28C,
  0x550C_7DC3_D5FF_B4E2,
  0x72BE_5D74_F27B_896F,
  0x80DE_B1FE_3B16_96B1,
  0x9BDC_06A7_25C7_1235,
  0xC19B_F174_CF69_2694,
  0xE49B_69C1_9EF1_4AD2,
  0xEFBE_4786_384F_25E3,
  0x0FC1_9DC6_8B8C_D5B5,
  0x240C_A1CC_77AC_9C65,
  0x2DE9_2C6F_592B_0275,
  0x4A74_84AA_6EA6_E483,
  0x5CB0_A9DC_BD41_FBD4,
  0x76F9_88DA_8311_53B5,
  0x983E_5152_EE66_DFAB,
  0xA831_C66D_2DB4_3210,
  0xB003_27C8_98FB_213F,
  0xBF59_7FC7_BEEF_0EE4,
  0xC6E0_0BF3_3DA8_8FC2,
  0xD5A7_9147_930A_A725,
  0x06CA_6351_E003_826F,
  0x1429_2967_0A0E_6E70,
  0x27B7_0A85_46D2_2FFC,
  0x2E1B_2138_5C26_C926,
  0x4D2C_6DFC_5AC4_2AED,
  0x5338_0D13_9D95_B3DF,
  0x650A_7354_8BAF_63DE,
  0x766A_0ABB_3C77_B2A8,
  0x81C2_C92E_47ED_AEE6,
  0x9272_2C85_1482_353B,
  0xA2BF_E8A1_4CF1_0364,
  0xA81A_664B_BC42_3001,
  0xC24B_8B70_D0F8_9791,
  0xC76C_51A3_0654_BE30,
  0xD192_E819_D6EF_5218,
  0xD699_0624_5565_A910,
  0xF40E_3585_5771_202A,
  0x106A_A070_32BB_D1B8,
  0x19A4_C116_B8D2_D0C8,
  0x1E37_6C08_5141_AB53,
  0x2748_774C_DF8E_EB99,
  0x34B0_BCB5_E19B_48A8,
  0x391C_0CB3_C5C9_5A63,
  0x4ED8_AA4A_E341_8ACB,
  0x5B9C_CA4F_7763_E373,
  0x682E_6FF3_D6B2_B8A3,
  0x748F_82EE_5DEF_B2FC,
  0x78A5_636F_4317_2F60,
  0x84C8_7814_A1F0_AB72,
  0x8CC7_0208_1A64_39EC,
  0x90BE_FFFA_2363_1E28,
  0xA450_6CEB_DE82_BDE9,
  0xBEF9_A3F7_B2C6_7915,
  0xC671_78F2_E372_532B,
  0xCA27_3ECE_EA26_619C,
  0xD186_B8C7_21C0_C207,
  0xEADA_7DD6_CDE0_EB1E,
  0xF57D_4F7F_EE6E_D178,
  0x06F0_67AA_7217_6FBA,
  0x0A63_7DC5_A2C8_98A6,
  0x113F_9804_BEF9_0DAE,
  0x1B71_0B35_131C_471B,
  0x28DB_77F5_2304_7D84,
  0x32CA_AB7B_40C7_2493,
  0x3C9E_BE0A_15C9_BEBC,
  0x431D_67C4_9C10_0D4C,
  0x4CC5_D4BE_CB3E_42B6,
  0x597F_299C_FC65_7E2A,
  0x5FCB_6FAB_3AD6_FAEC,
  0x6C44_198C_4A47_5817,
]

func truncateResult<T>(h: [T]) -> ArraySlice<T> {
  h[0 ..< 4]
}

// MARK: - SHA2

enum SHA2 {
  private static func preprocessMessage(message: [UInt8],
                                        messageLengthBits: Int) -> [UInt8]
  {
    var preprocessedMessage = message
    // Pre-processing: adding a single 1 bit
    // Notice: the input bytes are considered as bits strings,
    // where the first bit is the most significant bit of the byte.
    preprocessedMessage.append(0x80)

    // Pre-processing: padding with zeros
    // append "0" bit until message length in bits ≡ 448 (mod 512)
    let desiredMessageLengthModulo = messageLengthBits - 8
    var messageLength = preprocessedMessage.count
    var paddingCounter = 0
    while messageLength % messageLengthBits != desiredMessageLengthModulo {
      paddingCounter += 1
      messageLength += 1
    }
    preprocessedMessage += [UInt8](repeating: 0, count: paddingCounter)
    // append original length in bits mod (2 pow 64) to message
    preprocessedMessage.reserveCapacity(preprocessedMessage.count + 4)
    let lengthInBits = message.count * 8
    let lengthBytes = Representations.toUInt8Array(value: lengthInBits, length: 64 / 8)
    preprocessedMessage += lengthBytes
    return preprocessedMessage
  }

  // MARK: 64 bit version

  static func hash64Bit(message: [UInt8]) -> [UInt8] {
    // Initialize variables:
    var a0 = h[0] // A
    var b0 = h[1] // B
    var c0 = h[2] // C
    var d0 = h[3] // D
    var e0 = h[4] // E
    var f0 = h[5] // F
    var g0 = h[6] // G
    var h0 = h[7] // H

    // Pre-processing
    let preprocessedMessage = preprocessMessage(message: message,
                                                messageLengthBits: blockSize)

    // Process the message in successive 512-bit chunks:
    let chunkSizeBytes = 1024 / 8
    for chunk in preprocessedMessage.splitToChuncks(chunkSizeBytes) {
      // Break chunk into sixteen 32-bit big-endian words w[i], 0 ≤ i ≤ 15
      // Extend the sixteen 32-bit words into eighty 32-bit words:
      var M = [UInt64](repeating: 0, count: k.count)

      for x in 0 ..< M.count {
        switch x {
        case 0 ... 15:
          let start = chunk.startIndex + (x * MemoryLayout.size(ofValue: M[x]))
          let end = start + MemoryLayout.size(ofValue: M[x])
          let le = Representations.mergeToUInt64Array(slice: chunk[start ..< end])[0]
          M[x] = le.bigEndian
        default:
          let s0 = M[x - 15].rotateRight(1) ^ M[x - 15].rotateRight(8) ^ M[x - 15] >> 7
          let s1 = M[x - 2].rotateRight(19) ^ M[x - 2].rotateRight(61) ^ M[x - 2] >> 6
          M[x] = M[x - 16] &+ s0 &+ M[x - 7] &+ s1
        }
      }

      // Initialize hash value for this chunk:
      var A = a0
      var B = b0
      var C = c0
      var D = d0
      var E = e0
      var F = f0
      var G = g0
      var H = h0

      // Main loop:
      for i in 0 ..< k.count {
        let S1 = E.rotateRight(14) ^ E.rotateRight(18) ^ E.rotateRight(41)
        let ch = (E & F) ^ (~E & G)
        let temp1 = H &+ S1 &+ ch &+ UInt64(k[i]) &+ M[i]
        let S0 = A.rotateRight(28) ^ A.rotateRight(34) ^ A.rotateRight(39)
        let maj = (A & B) ^ (A & C) ^ (B & C)
        let temp2 = S0 &+ maj

        H = G
        G = F
        F = E
        E = D &+ temp1
        D = C
        C = B
        B = A
        A = temp1 &+ temp2
      }

      // Add this chunk's hash to result so far:
      a0 = (a0 &+ A)
      b0 = (b0 &+ B)
      c0 = (c0 &+ C)
      d0 = (d0 &+ D)
      e0 = (e0 &+ E)
      f0 = (f0 &+ F)
      g0 = (g0 &+ G)
      h0 = (h0 &+ H)
    }

    // Produce the final hash value (big-endian) as a 160 bit number:
    var result = [UInt8]()
    result.reserveCapacity(160 / 8)

    for item in truncateResult(h: [a0, b0, c0, d0, e0, f0, g0, h0]) {
      result += Representations.toUInt8Array(value: item.bigEndian.reverseBytes())
    }

    return result
  }

  static func hash64Bit(message: String) -> String {
    Representations.toHexadecimalString(
      bytes: hash64Bit(message: Array(message.utf8))
    )
  }
}

// MARK: - Representations

enum Representations {
  // Array of bytes with optional padding (little-endian)
  static func toUInt8Array<T>(value: T, length: Int? = nil) -> [UInt8] {
    let totalBytes = length ?? MemoryLayout<T>.size
    var copyOfValue = value

    return withUnsafePointer(to: &copyOfValue) {
      Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(OpaquePointer($0)), count: totalBytes)).reversed()
    }
  }

  // Merge Array of UInt8 to array of UInt32
  static func mergeToUInt32Array(slice: ArraySlice<UInt8>) -> [UInt32] {
    var result = [UInt32]()
    result.reserveCapacity(16)

    for idx in stride(from: slice.startIndex, to: slice.endIndex, by: MemoryLayout<UInt32>.size) {
      let val1 = UInt32(slice[idx.advanced(by: 3)]) << 24
      let val2 = UInt32(slice[idx.advanced(by: 2)]) << 16
      let val3 = UInt32(slice[idx.advanced(by: 1)]) << 8
      let val4 = UInt32(slice[idx])
      let val: UInt32 = val1 | val2 | val3 | val4
      result.append(val)
    }

    return result
  }

  // Merge Array of UInt8 to array of UInt64
  static func mergeToUInt64Array(slice: ArraySlice<UInt8>) -> [UInt64] {
    var result = [UInt64]()
    result.reserveCapacity(32)

    for idx in stride(from: slice.startIndex, to: slice.endIndex, by: MemoryLayout<UInt64>.size) {
      let val1 = UInt64(slice[idx.advanced(by: 7)]) << 56
      let val2 = UInt64(slice[idx.advanced(by: 6)]) << 48
      let val3 = UInt64(slice[idx.advanced(by: 5)]) << 40
      let val4 = UInt64(slice[idx.advanced(by: 4)]) << 32
      let val5 = UInt64(slice[idx.advanced(by: 3)]) << 24
      let val6 = UInt64(slice[idx.advanced(by: 2)]) << 16
      let val7 = UInt64(slice[idx.advanced(by: 1)]) << 8
      let val8 = UInt64(slice[idx])
      let val: UInt64 = val1 | val2 | val3 | val4 | val5 | val6 | val7 | val8
      result.append(val)
    }

    return result
  }

  // Return hexadecimal string representation of Array<UInt8>
  static func toHexadecimalString(bytes: [UInt8]) -> String {
    var hexString = String()
    for byte in bytes {
      hexString += String(format: "%02x", byte)
    }

    return hexString
  }
}
