//
//  Collection.swift
//  iOSCommonLibraries
//
//  Created by Dinesh Harjani on 25/10/24.
//

import Foundation

// MARK: - Collection Extension

public extension Collection {

    var hasItems: Bool { count > 0 }
    
    func toArray() -> [Element] {
        return map { $0 }
    }
}
