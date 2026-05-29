//
//  Float.swift
//  nRF-Connect
//  iOSCommonLibraries
//
//  Created by Dinesh Harjani on 20/11/2018.
//  Created by Dinesh Harjani on 19/3/25.
//

import Foundation

// MARK: - Float Extension

public extension Float {
    
    // MARK: init
    
    init(_ data: Data) {
        let tempData = data.littleEndianBytes(as: UInt32.self)
        var mantissa = Int32(tempData & 0x00FFFFFF)
        let exponent = Int8(bitPattern: UInt8(tempData >> 24))

        if mantissa >= Int32(ReservedFloatValues.positiveINF.rawValue)
            && mantissa <= Int32(ReservedFloatValues.negativeINF.rawValue) {
            self = .nan
        } else {
            if mantissa >= 0x800000 {
                mantissa = -((0xFFFFFF + 1) - mantissa)
            }
            let magnitude = pow(10.0, Float(exponent))
            self = Float32(mantissa) * Float32(magnitude)
        }
    }
    
    // MARK: SFloat
    
    init(asSFloat data: Data) {
        let sfloatData = UInt16(data.littleEndianBytes(as: UInt16.self))
        var mantissa = Int16(sfloatData & 0x0FFF)
        var exponent = Int8(sfloatData >> 12)
        if exponent >= 0x0008 {
            exponent = -( (0x000F + 1) - exponent )
        }
        
        if mantissa >= SFloatReserved.firstReservedValue.rawValue && mantissa <= SFloatReserved.negativeINF.rawValue {
            self = Float.reservedValues[Int(mantissa - SFloatReserved.firstReservedValue.rawValue)]
        } else {
            if mantissa > SFloatReserved.nres.rawValue {
                mantissa = -((0x0FFF + 1) - mantissa)
            }
            let magnitude = pow(10.0, Double(exponent))
            self = Float(mantissa) * Float(magnitude)
        }
    }
    
    // MARK: reservedValues
    
    static let reservedValues: [Float] = [.infinity, .nan, .nan, .nan, -.infinity]
}

// MARK: - ReservedFloatValues

public enum ReservedFloatValues: UInt32 {
    case positiveINF = 0x007FFFFE
    case nan = 0x007FFFFF
    case nres = 0x00800000
    case reserved = 0x00800001
    case negativeINF = 0x00800002
    
    static let firstReservedValue = ReservedFloatValues.positiveINF
}

// MARK: - SFloatReserved

public enum SFloatReserved: Int16 {
    case positiveINF = 0x07FE
    case nan = 0x07FF
    case nres = 0x0800
    case reserved = 0x0801
    case negativeINF = 0x0802
    
    public static let firstReservedValue = SFloatReserved.positiveINF
    public static let byteSize = MemoryLayout<UInt16>.size // 2 bytes
}
