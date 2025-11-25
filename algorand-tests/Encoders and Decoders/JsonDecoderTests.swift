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

//   JsonDecoderTests.swift

@testable import pera_staging
import Testing
import Foundation

@Suite("Encoders and Decoders - JsonDecoder Tests", .tags(.encoderDecoder))
struct JsonDecoderTests {
    
    // MARK: - Properties
    
    private let decoder: JSONDecoder
    
    // MARK: - Initialisers
    
    init() {
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .kebabCase
    }
    
    // MARK: - Tests
    
    @Test("Decoding JSON with single word keys using kebabCase key decoding strategy")
    func decodingSingleWordKeys() throws {
        
        let rawJson = """
            {
                "foo": 123,
                "bar": "Hello World",
                "buzz": true
            }
        """
        
        let data = try #require(rawJson.data(using: .utf8))
        let expectedResult = SingleWordKeyModel(foo: 123, bar: "Hello World", buzz: true)
        let result = try decoder.decode(SingleWordKeyModel.self, from: data)
        
        #expect(result == expectedResult)
    }
    
    @Test("Decoding JSON with multiple words keys using kebabCase key decoding strategy")
    func decodingMultipleWordsKeys() throws {
        
        let rawJson = """
            {
                "foo-foo": 123,
                "bar-bar-bar": "Hello World",
                "buzz-buzz-buzz-buzz": true
            }
        """
        
        let data = try #require(rawJson.data(using: .utf8))
        let expectedResult = MultipleWordsKeyModel(fooFoo: 123, barBarBar: "Hello World", buzzBuzzBuzzBuzz: true)
        let result = try decoder.decode(MultipleWordsKeyModel.self, from: data)
        
        #expect(result == expectedResult)
    }
    
    @Test("Decoding JSON with mixed word count keys using kebabCase key decoding strategy")
    func decodingMixedWordCountKeys() throws {
        
        let rawJson = """
            {
                "foo-foo": 123,
                "bar": "Hello World",
                "buzz-buzz-buzz": true
            }
        """
        
        let data = try #require(rawJson.data(using: .utf8))
        let expectedResult = MixedWordCountKeysModel(fooFoo: 123, bar: "Hello World", buzzBuzzBuzz: true)
        let result = try decoder.decode(MixedWordCountKeysModel.self, from: data)
        
        #expect(result == expectedResult)
    }
    
    @Test("Decoding invalid JSON using kebabCase key decoding strategy")
    func decodingInvalidJSon() throws {
        let rawJson = """
            {
                "foo-foo": 123,
                "bar": "Hello World",
                "buzz-buzz-buzz": true-but-invalid{}
            }
        """
        
        let data = try #require(rawJson.data(using: .utf8))
        var result: MixedWordCountKeysModel?
        var outputError: Error?
        
        do {
            result = try decoder.decode(MixedWordCountKeysModel.self, from: data)
        } catch {
            outputError = error
        }
        
        let decodingError = try #require(outputError as? DecodingError)
        
        #expect(result == nil)
        #expect(decodingError.isDataCorrupted)
    }
    
    @Test("Decoding valid JSON additional key using kebabCase key decoding strategy")
    func decodingWithAdditionalKey() throws {
        
        let rawJson = """
            {
                "foo-foo": 123,
                "bar": "Hello World",
                "buzz-buzz-buzz": true,
                "spanish-inquisition": "Nobody expected me"
            }
        """
        
        let data = try #require(rawJson.data(using: .utf8))
        let expectedResult = MixedWordCountKeysModel(fooFoo: 123, bar: "Hello World", buzzBuzzBuzz: true)
        let result = try decoder.decode(MixedWordCountKeysModel.self, from: data)
        
        #expect(result == expectedResult)
    }
    
    @Test("Decoding valid JSON missing key using kebabCase key decoding strategy")
    func decodingWithMissingKey() throws {
        
        let rawJson = """
            {
                "foo-foo": 123,
                "buzz-buzz-buzz": true,
            }
        """
        
        let data = try #require(rawJson.data(using: .utf8))
        var result: MixedWordCountKeysModel?
        var outputError: Error?
        
        do {
            result = try decoder.decode(MixedWordCountKeysModel.self, from: data)
        } catch {
            outputError = error
        }
        
        let decodingError = try #require(outputError as? DecodingError)
        
        #expect(result == nil)
        #expect(decodingError.isKeyNotFound)
    }
}

private struct SingleWordKeyModel: Decodable, Equatable {
    let foo: Int
    let bar: String
    let buzz: Bool
}

private struct MultipleWordsKeyModel: Decodable, Equatable {
    let fooFoo: Int
    let barBarBar: String
    let buzzBuzzBuzzBuzz: Bool
}

private struct MixedWordCountKeysModel: Decodable, Equatable {
    let fooFoo: Int
    let bar: String
    let buzzBuzzBuzz: Bool
}

private extension DecodingError {
    
    var isDataCorrupted: Bool {
        switch self {
        case .dataCorrupted: true
        default: false
        }
    }
    
    var isKeyNotFound: Bool {
        switch self {
        case .keyNotFound: true
        default: false
        }
    }
}
