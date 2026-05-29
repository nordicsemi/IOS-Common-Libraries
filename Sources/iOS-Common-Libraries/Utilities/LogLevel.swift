//
//  LogLevel.swift
//  iOSCommonLibraries
//
//  Created by Sylwester Zielinski on 13/01/2026.
//

public enum LogLevel: Int, Codable, CaseIterable, Identifiable {
    case info = 0
    case debug = 1
    case error = 2
    
    public var id: Self { self }
}
