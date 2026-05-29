//
//  Date.swift
//  iOS-Common-Libraries
//
//  Created by Dinesh Harjani on 9/8/22.
//

import Foundation

// MARK: - Date Extension

public extension Date {
    
    // MARK: Constants
    
    static let DataSize = MemoryLayout<UInt16>.size + 5 * MemoryLayout<UInt8>.size
    
    // MARK: init
    
    init?(_ data: Data) {
        guard data.count >= Self.DataSize else { return nil }
        
        var offset = 0
        let year = data.littleEndianBytes(atOffset: offset, as: UInt16.self)
        offset += MemoryLayout<UInt16>.size
        let month = data.littleEndianBytes(atOffset: offset, as: UInt8.self)
        offset += MemoryLayout<UInt8>.size
        let day = data.littleEndianBytes(atOffset: offset, as: UInt8.self)
        offset += MemoryLayout<UInt8>.size
        let hours = data.littleEndianBytes(atOffset: offset, as: UInt8.self)
        offset += MemoryLayout<UInt8>.size
        let minutes = data.littleEndianBytes(atOffset: offset, as: UInt8.self)
        offset += MemoryLayout<UInt8>.size
        let seconds = data.littleEndianBytes(atOffset: offset, as: UInt8.self)

        let calendar = Calendar.current
        let dateComponents = DateComponents(calendar: calendar, year: year, month: month, day: day, hour: hours, minute: minutes, second: seconds)
        guard let date = calendar.date(from: dateComponents) else { return nil }
        self = date
    }
    
    // MARK: toData()
    
    enum Options: RegisterValue, Option {
        case appendTimeZone
        case appendDSTOffset
    }
    
    func toData(options: BitField<Options> = []) -> Data? {
        let components = Calendar.current.dateComponents([
            .year, .month, .day, .hour, .minute, .second
        ], from: self)
        
        var output = Data()
        guard let yearComp = components.year, let monthComp = components.month,
              let dayComp = components.day, let hoursComp = components.hour,
              let minutesComp = components.minute, let secondsComp = components.second else { return nil }
        var year = UInt16(yearComp)
        output.append(contentsOf: Data(bytes: &year, count: MemoryLayout<UInt16>.size))
        output.append(contentsOf: Data(repeating: UInt8(monthComp), count: MemoryLayout<UInt8>.size))
        output.append(contentsOf: Data(repeating: UInt8(dayComp), count: MemoryLayout<UInt8>.size))
        output.append(Data(repeating: UInt8(hoursComp), count: MemoryLayout<UInt8>.size))
        output.append(Data(repeating: UInt8(minutesComp), count: MemoryLayout<UInt8>.size))
        output.append(Data(repeating: UInt8(secondsComp), count: MemoryLayout<UInt8>.size))
        
        if options.contains(.appendTimeZone) {
            // Date is always in UTC, and TimeZone Characteristic TimeZone is
            // relative to UTC, so zero.
            output.append(Data(repeating: 0, count: MemoryLayout<UInt8>.size))
        }
        
        if options.contains(.appendDSTOffset), let timeZone = TimeZone(identifier: "UTC") {
            let utcDSTOffset = Measurement<UnitDuration>(value: timeZone.daylightSavingTimeOffset(for: self), unit: .seconds)
            let utcDSTOffsetMinutes = utcDSTOffset.converted(to: .minutes).value
            // DST Offset is in 15 minute intervals. So a 2 hour offset,
            // would be 120 / 15 == 8.
            let utcDSTOffsetInIntervals = utcDSTOffsetMinutes / 15.0
            output.append(Data(repeating: UInt8(utcDSTOffsetInIntervals),
                               count: MemoryLayout<UInt8>.size))
        }
        
        return output
    }
    
    // MARK: currentYear()
    
    static func currentYear() -> Int {
        guard let calendar = NSCalendar(calendarIdentifier: .gregorian) else {
            fatalError("Failed call to NSCalendar with Gregorian Calendar.")
        }
        return calendar.component(.year, from: Date())
    }
}
