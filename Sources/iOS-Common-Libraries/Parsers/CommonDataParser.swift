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
    case unsignedInt8
    case unsignedInt16
    case unsignedInt32
    case anyUnsignedInt
    case signedInt8
    case signedInt16
    case signedInt32
    case anySignedInt
    case boolean
    case utf8
    
    // MARK: CustomStringConvertible
    
    public var description: String {
        switch self {
        case .byteArray:
            return "Byte Array"
        case .unsignedInt8:
            return "UInt8"
        case .unsignedInt16:
            return "UInt16"
        case .unsignedInt32:
            return "UInt32"
        case .anyUnsignedInt:
            return "Any UInt (8, 16, 32, 64)"
        case .signedInt8:
            return "Int8"
        case .signedInt16:
            return "Int16"
        case .signedInt32:
            return "Int32"
        case .anySignedInt:
            return "Any Int (8, 16, 32, 64)"
        case .boolean:
            return "Boolean"
        case .utf8:
            return "UTF-8"
        }
    }
    
    // MARK: dataSizeRequirement
    
    public var dataSizeRequirement: NordicDataParserValidSize {
        switch self {
        case .unsignedInt8:
            return .exactly(MemoryLayout<UInt8>.size)
        case .unsignedInt16:
            return .exactly(MemoryLayout<UInt16>.size)
        case .unsignedInt32:
            return .exactly(MemoryLayout<UInt32>.size)
        case .byteArray, .anyUnsignedInt:
            return .atLeast(MemoryLayout<UInt8>.size)
        case .signedInt8:
            return .exactly(MemoryLayout<Int8>.size)
        case .signedInt16:
            return .exactly(MemoryLayout<Int16>.size)
        case .signedInt32:
            return .exactly(MemoryLayout<Int32>.size)
        case .anySignedInt:
            return .atLeast(MemoryLayout<Int8>.size)
        case .boolean:
            return .exactly(MemoryLayout<Int8>.size)
        case .utf8:
            return .anySize
        }
    }
    
    // MARK: parse(_:)
    
    internal func parse(_ dataString: String) -> Data? {
        switch self {
        case .byteArray:
            return Data(hexString: dataString)
        case .unsignedInt8:
            guard let number = UInt8(dataString) else { return nil }
            return Data(repeating: number, count: 1)
        case .unsignedInt16:
            guard let number = UInt16(dataString) else { return nil }
            return Data(number.littleEndianBytes)
        case .unsignedInt32:
            guard let number = UInt32(dataString) else { return nil }
            return Data(number.littleEndianBytes)
        case .anyUnsignedInt:
            guard let number = UInt(dataString) else { return nil }
            if number < UInt8.max {
                return CommonDataParser.unsignedInt8.parse(dataString)
            } else if number < UInt16.max {
                return CommonDataParser.unsignedInt16.parse(dataString)
            } else if number < UInt32.max {
                return CommonDataParser.unsignedInt32.parse(dataString)
            }
            return Data(number.littleEndianBytes)
        case .signedInt8:
            guard let number = Int8(dataString) else { return nil }
            return Data(number.littleEndianBytes)
        case .signedInt16:
            guard let number = Int16(dataString) else { return nil }
            return Data(number.littleEndianBytes)
        case .signedInt32:
            guard let number = Int32(dataString) else { return nil }
            return Data(number.littleEndianBytes)
        case .anySignedInt:
            guard let number = Int(dataString) else { return nil }
            if number < Int8.max {
                return CommonDataParser.signedInt8.parse(dataString)
            } else if number < Int16.max {
                return CommonDataParser.signedInt16.parse(dataString)
            } else if number < Int32.max {
                return CommonDataParser.signedInt32.parse(dataString)
            }
            return Data(number.littleEndianBytes)
        case .boolean:
            return Data(repeating: dataString.hasItems ? 1 : 0, count: 1)
        case .utf8:
            return dataString.data(using: .utf8)
        default:
            return nil
        }
    }
    
    // MARK: callAsFunction
    
    public func callAsFunction(_ item: Data) -> String? {
        guard isValid(item) else { return nil }
        switch self {
        case .byteArray:
            guard !item.isEmpty else { return "" }
            return item.hexEncodedString(options: [.twoByteSpacing, .upperCase])
        case .unsignedInt8:
            return String(item.littleEndianBytes(as: UInt8.self))
        case .unsignedInt16:
            return String(item.littleEndianBytes(as: UInt16.self))
        case .unsignedInt32:
            return String(item.littleEndianBytes(as: UInt32.self))
        case .anyUnsignedInt:
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
        case .signedInt8:
            return String(item.littleEndianBytes(as: Int8.self))
        case .signedInt16:
            return String(item.littleEndianBytes(as: Int16.self))
        case .signedInt32:
            return String(item.littleEndianBytes(as: Int32.self))
        case .anySignedInt:
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

// MARK: - FixedWidthInteger

public extension FixedWidthInteger {
    
    var littleEndianBytes: [UInt8] {
        withUnsafeBytes(of: littleEndian, Array.init)
    }
    
    var bigEndianBytes: [UInt8] {
        withUnsafeBytes(of: bigEndian, Array.init)
    }
}
