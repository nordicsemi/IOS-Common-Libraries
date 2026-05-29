//
//  String.swift
//  iOSCommonLibraries
//
//  Created by Dinesh Harjani on 2/4/25.
//

import Foundation

extension String {
    
    func inserting(separator: String, every n: Int) -> String {
        let characters = Array(self)
        let addedSeparators: Int = characters.count / n
        var result: String = ""
        result.reserveCapacity(characters.count + addedSeparators)
        for i in stride(from: 0, to: characters.count, by: n) {
            result.append(contentsOf: characters[i..<min(i + n, characters.count)])
            if i + n < characters.count {
                result.append(separator)
            }
        }
        return result
    }
}
