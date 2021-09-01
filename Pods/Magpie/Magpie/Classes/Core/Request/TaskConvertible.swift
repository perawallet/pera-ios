//
//  TaskConvertible.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 5.10.2018.
//

import Foundation

public protocol TaskConvertible: Printable {
    var taskIdentifier: Int { get }
    var inProgress: Bool { get }

    func cancelNow()
}
