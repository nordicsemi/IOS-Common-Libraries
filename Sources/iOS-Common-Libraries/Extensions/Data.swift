//
//  Data.swift
//  iOSCommonLibraries
//
//  Created by Dinesh Harjani on 18/8/22.
//  Copyright © 2020 Nordic Semiconductor. All rights reserved.
//

import Foundation
import Compression

// MARK: - Byte Handling

public extension Data {
    
    func canRead<T: FixedWidthInteger>(_ dataType: T.Type, atOffset offset: Int) -> Bool {
        return offset + MemoryLayout<T>.size <= count
    }
    
    func littleEndianBytesUInt16(atOffset offset: Int = 0) -> UInt16 {
        let byteLength = MemoryLayout<UInt16>.size
        let subdata = self.subdata(in: offset..<offset + byteLength)
        return subdata.withUnsafeBytes {
            $0.load(as: UInt16.self).littleEndian
        }
    }
    
    func littleEndianBytes<T: FixedWidthInteger>(atOffset offset: Int = 0, as: T.Type) -> Int {
        let byteLength = MemoryLayout<T>.size
        return subdata(in: offset ..< offset + byteLength).withUnsafeBytes { Int($0.load(as: T.self)) }
    }

    func bigEndianBytes<T: FixedWidthInteger>(atOffset offset: Int = 0, as: T.Type) -> Int {
        let byteLength = MemoryLayout<T>.size
        return subdata(in: offset ..< offset + byteLength).withUnsafeBytes { Int(T(bigEndian: $0.load(as: T.self))) }
    }
    
    private static let byteCountFormatter = ByteCountFormatter()
    func sizeString(units: ByteCountFormatter.Units = [.useAll], countStyle: ByteCountFormatter.CountStyle = .file) -> String {
        Self.byteCountFormatter.allowedUnits = units
        Self.byteCountFormatter.countStyle = .file
        return Self.byteCountFormatter.string(fromByteCount: Int64(count))
    }
}

// MARK: - Compression

@available(iOS 14.0, macCatalyst 14.0, macOS 11.0, *)
public extension Data {
    
    private static let PageSize = 128
    private static let AppLog = NordicLog(category: "Data", subsystem: NordicLog.iOSCommonLibrarySubsystem)
    
    // MARK: compressed()
    
    func compressed() -> Data {
        var compressedData = Data()
        do {
            var index = 0
            let bufferSize = count
            
            let inputFilter = try InputFilter(.compress, using: .lzfse) { (length: Int) -> Data? in
                let rangeLength = Swift.min(length, bufferSize - index)
                let dataSlice = self.subdata(in: index..<index + rangeLength)
                index += rangeLength
                return dataSlice
            }
            
            while let page = try inputFilter.readData(ofLength: Self.PageSize) {
                compressedData.append(page)
            }
        } catch {
            Self.AppLog.error("\(#function) Error: \(error.localizedDescription)")
            return self
        }
        
        #if DEBUG
        Self.AppLog.debug("\(#function) \(sizeString()) to \(compressedData.sizeString()).")
        #endif
        return compressedData
    }
    
    // MARK: decompress()
    
    func decompress<T: Codable>(as dataType: T.Type) -> T? {
        return try? JSONDecoder().decode(dataType, from: decompressed())
    }
    
    func decompressed() -> Data {
        var decompressedData = Data()
        do {
            let outputFilter = try OutputFilter(.decompress, using: .lzfse) { data in
                guard let data = data else { return }
                decompressedData.append(data)
            }

            var index = 0
            let bufferSize = self.count
            while true {
                let rangeLength = Swift.min(Self.PageSize, bufferSize - index)
                let subdata = self.subdata(in: index..<index + rangeLength)
                index += rangeLength
                try outputFilter.write(subdata)
                guard rangeLength > 0 else { break }
            }
        } catch {
            Self.AppLog.error("\(#function) Error: \(error.localizedDescription)")
            return self
        }
        Self.AppLog.debug("\(#function) \(decompressedData.sizeString()).")
        return decompressedData
    }
}

// MARK: - Hex Encoding

public extension Data {
    
    // Source:
    /**
    Source: https://github.com/krzyzanowskim/CryptoSwift/issues/546
    */
    init?(hexString: String) {
        guard hexString.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil else { return nil }
        
        let length = hexString.count / 2
        var data = Data(capacity: length)
        for i in 0..<length {
            let j = hexString.index(hexString.startIndex, offsetBy: i * 2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var byte = UInt8(bytes, radix: 16) {
                data.append(&byte, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
    
    // MARK: HexEncodingOptions
    
    enum HexEncodingOptions: RegisterValue, Option {
        case upperCase
        case byteSpacing
        case prepend0x
        case twoByteSpacing
        case reverseEndianness
    }

    // MARK: hexEncodedString
    
    func hexEncodedString(options: BitField<HexEncodingOptions> = [], separator: String = "") -> String {
        guard !isEmpty else { return "0 bytes" }
        
        var format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        if options.contains(.byteSpacing) {
            format.append(" ")
        }

        var bytes = self
        if options.contains(.reverseEndianness) {
            bytes.reverse()
        }
        var body: String = options.contains(.prepend0x) ? "0x" : ""
        if options.contains(.byteSpacing) {
            body.reserveCapacity(
                options.contains(.prepend0x) ? 1 : 0 + bytes.count * 3
            )
        } else {
            body.reserveCapacity(
                options.contains(.prepend0x) ? 1 : 0 + bytes.count * 2
            )
        }
        
        autoreleasepool {
            body.append(contentsOf: bytes.map {
                String(format: format, $0)
            }.joined())
        }
        
        if options.contains(.twoByteSpacing) {
            autoreleasepool {
                body = body.inserting(separator: " ", every: 4)
            }
        }

        return body
    }
}
