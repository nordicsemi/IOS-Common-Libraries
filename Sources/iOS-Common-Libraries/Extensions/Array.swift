//
//  Array.swift
//  iOS-Common-Libraries
//
//  Created by Dinesh Harjani on 23/5/24.
//

import Foundation

// MARK: - Array Extension

public extension Array {
    
    func firstIndex<T: Equatable>(where keyPath: KeyPath<Self.Element, T>, equals value: T) -> Self.Index? {
        return firstIndex(where: { $0[keyPath: keyPath] == value })
    }
    
    func firstTrueIndex(for keyPath: KeyPath<Self.Element, Bool>) -> Self.Index? {
        return firstIndex(where: { $0[keyPath: keyPath] })
    }
}
