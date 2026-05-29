//
//  LogRecord.swift
//  iOSCommonLibraries
//
//  Created by Sylwester Zielinski on 13/01/2026.
//

import Foundation

public struct LogRecord {
    public let message: String
    public let level: LogLevel
    public let timestamp: Date = Date()
}
