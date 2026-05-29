//
//  Double.swift
//  iOSCommonLibraries
//
//  Created by Sylwester Zieliński on 02/10/2025.
//

import Foundation

// MARK: - Double Extension

public extension Double {
    
    // MARK: init
    
    init(_ data: Data) {
        let tempData = data.littleEndianBytes(as: UInt32.self)
        
        guard tempData != ReservedDoubleValues.nan.rawValue else {
            self = Double.nan
            return
        }
        
        var mantissa = Int32(tempData & 0x00FFFFFF)
        let exponent = Int8(bitPattern: UInt8(tempData >> 24))

        if mantissa >= Int32(ReservedFloatValues.positiveINF.rawValue)
            && mantissa <= Int32(ReservedFloatValues.negativeINF.rawValue) {
            self = .nan
        } else {
            if mantissa >= 0x800000 {
                mantissa = -((0xFFFFFF + 1) - mantissa)
            }
            let magnitude = pow(10.0, Double(exponent))
            self = Double(mantissa) * Double(magnitude)
        }
    }
}

private enum ReservedDoubleValues: UInt32 {
    case nan = 0x007FFFFF
}
