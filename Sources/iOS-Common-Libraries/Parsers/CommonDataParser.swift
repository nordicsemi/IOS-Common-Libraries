//
//  CommonDataParser.swift
//  iOSCommonLibraries
//
//  Created by Dinesh Harjani on 27/5/25.
//  Copyright © 2025 Nordic Semiconductor. All rights reserved.
//

import Foundation

// MARK: - CommonDataParser

public enum CommonDataParser: String, RawRepresentable, CustomStringConvertible, NordicDataParser {
    case byteArray
    case unsignedInt
    case signedInt
    case boolean
    case utf8
    
    // MARK: CustomStringConvertible
    
    public var description: String {
        switch self {
        case .byteArray:
            return "Byte Array"
        case .unsignedInt:
            return "Unsigned Int"
        case .signedInt:
            return "Signed Int"
        case .boolean:
            return "Boolean"
        case .utf8:
            return "UTF-8"
        }
    }
    
    // MARK: dataSizeRequirement
    
    public var dataSizeRequirement: NordicDataParserValidSize {
        switch self {
        case .byteArray:
            return .atLeast(MemoryLayout<UInt8>.size)
        case .unsignedInt:
            return .anyOf([MemoryLayout<UInt8>.size, MemoryLayout<UInt16>.size, MemoryLayout<UInt32>.size])
        case .signedInt:
            return .anyOf([MemoryLayout<Int8>.size, MemoryLayout<Int16>.size, MemoryLayout<Int32>.size])
        case .boolean:
            return .exactly(MemoryLayout<Int8>.size)
        case .utf8:
            return .anySize
        }
    }
    
    // MARK: callAsFunction
    
    public func callAsFunction(_ item: Data) -> String? {
        switch self {
        case .byteArray:
            guard !item.isEmpty else { return "" }
            return item.hexEncodedString(options: [.twoByteSpacing, .upperCase])
        case .unsignedInt:
            let intValue: Int
            switch item.count {
            case MemoryLayout<UInt8>.size:
                intValue = item.littleEndianBytes(as: UInt8.self)
            case MemoryLayout<UInt16>.size:
                intValue = item.littleEndianBytes(as: UInt16.self)
            case MemoryLayout<UInt32>.size:
                intValue = item.littleEndianBytes(as: UInt32.self)
            default:
                return nil
            }
            return String(intValue)
        case .signedInt:
            let intValue: Int
            switch item.count {
            case MemoryLayout<Int8>.size:
                intValue = item.littleEndianBytes(as: Int8.self)
            case MemoryLayout<Int16>.size:
                intValue = item.littleEndianBytes(as: Int16.self)
            case MemoryLayout<Int32>.size:
                intValue = item.littleEndianBytes(as: Int32.self)
            default:
                return nil
            }
            return String(intValue)
        case .boolean:
            guard item.hasItems else { return nil }
            let intValue = item.littleEndianBytes(as: Int8.self)
            let bool = intValue > 0
            return bool ? "True" : "False"
        case .utf8:
            return String(data: item, encoding: .utf8) as String?
        }
    }
}
