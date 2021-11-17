// Copyright © 2019 hipolabs. All rights reserved.

import Foundation

public protocol DeeplinkParser {
//    associatedtype Pattern: DeeplinkPattern
//    associatedtype Destination: Route
//
//    var host: String { get }
//    var matchers: [Pattern: NSRegularExpression] { get }
//
//    func discover(url: URL) -> Destination?
//    func makeDestination(with urlComponents: DeeplinkComponents, for match: (Pattern, NSTextCheckingResult)) -> Destination?
}

extension DeeplinkParser {
//    public func discover(url: URL) -> Destination? {
//        let urlComponents = DeeplinkComponents(url: url, deeplinkHost: host)
//        return findMatch(in: urlComponents.path).unwrap {
//            makeDestination(with: urlComponents, for: $0)
//        }
//    }
}

extension DeeplinkParser {
//    public func formMatchers() -> [Pattern: NSRegularExpression] {
//        return Pattern.allCases.reduce(into: [:], { $0[$1] = try? NSRegularExpression(pattern: $1.rawValue, options: .caseInsensitive) })
//    }
//
//    public func findMatch(in path: String) -> (Pattern, NSTextCheckingResult)? {
//        if path.isEmpty { return nil }
//        return matchers.findFirst(nonNil: { $0.firstMatch(in: path, options: [], range: NSRange(path.startIndex..<path.endIndex, in: path)) })
//    }
}

public protocol DeeplinkPattern: Hashable, RawRepresentable, CaseIterable where RawValue == String { }
