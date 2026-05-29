//
//  Sequence.swift
//  iOS-Common-Libraries
//
//  Created by Dinesh Harjani on 4/2/20.
//  Copyright © 2020 Nordic Semiconductor. All rights reserved.
//

import Foundation

public extension Sequence {
    
    func filter<T: Equatable>(where keyPath: KeyPath<Element, T>, isEqualsTo includedValue: T) -> [Self.Element] {
        return filter { $0[keyPath: keyPath] == includedValue }
    }
    
    func first<T: Equatable>(where keyPath: KeyPath<Element, T>, isEqualsTo value: T) -> Self.Element? {
        return first { $0[keyPath: keyPath] == value }
    }
    
    func contains<T: Equatable>(where keyPath: KeyPath<Element, T>, isEqualsTo value: T) -> Bool {
        return contains { $0[keyPath: keyPath] == value }
    }
}
