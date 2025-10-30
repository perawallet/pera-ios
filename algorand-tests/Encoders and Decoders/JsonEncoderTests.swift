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

//   JsonEncoderTests.swift

@testable import pera_staging
import Testing
import Foundation

@Suite("Encoders and Decoders - JSONEncoder Tests", .tags(.encoderDecoder))
struct JsonEncoderTests {
    
    private let encoder: JSONEncoder
    
    // MARK: - Initialisers
    
    init() {
        encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .kebabCase
        encoder.outputFormatting = .sortedKeys
    }
    
    // MARK: - Tests
    
    @Test("Encoding JSON with single word keys using kebabCase key encoding strategy")
    func encodingSingleWordKeys() throws {
        
        let model = SingleWordKeyModel(foo: 123, bar: "Hello World!", buzz: true)
        
        let data = try encoder.encode(model)
        let rawData = try #require(String(data: data, encoding: .utf8))
        let expectedResult = #"{"bar":"Hello World!","buzz":true,"foo":123}"#
        
        #expect(rawData == expectedResult)
    }
    
    @Test("Encoding JSON with multiple words keys using kebabCase key encoding strategy")
    func encodingMultipleWordsKeys() throws {
        
        let model = MultipleWordsKeyModel(fooFoo: 123, barBarBar: "Hello World!", buzzBuzzBuzzBuzz: true)
        
        let data = try encoder.encode(model)
        let rawData = try #require(String(data: data, encoding: .utf8))
        let expectedResult = #"{"bar-bar-bar":"Hello World!","buzz-buzz-buzz-buzz":true,"foo-foo":123}"#
        
        #expect(rawData == expectedResult)
    }
    
    @Test("Encoding JSON with mixed word count keys using kebabCase key encoding strategy")
    func decodingMixedWordCountKeys() throws {
        
        let model = MixedWordCountKeysModel(fooFoo: 123, bar: "Hello World!", buzzBuzzBuzz: true)
        
        let data = try encoder.encode(model)
        let rawData = try #require(String(data: data, encoding: .utf8))
        let expectedResult = #"{"bar":"Hello World!","buzz-buzz-buzz":true,"foo-foo":123}"#
        
        #expect(rawData == expectedResult)
    }
}

private struct SingleWordKeyModel: Encodable {
    let foo: Int
    let bar: String
    let buzz: Bool
}

private struct MultipleWordsKeyModel: Encodable {
    let fooFoo: Int
    let barBarBar: String
    let buzzBuzzBuzzBuzz: Bool
}

private struct MixedWordCountKeysModel: Encodable {
    let fooFoo: Int
    let bar: String
    let buzzBuzzBuzz: Bool
}
