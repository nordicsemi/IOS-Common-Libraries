//
//  PipelineStage.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//  iOS-Common-Libraries
//
//  Created by Dinesh Harjani on 17/4/24.
//

import Foundation
import SwiftUI

// MARK: - PipelineStage

public protocol PipelineStage: Identifiable, Hashable, CaseIterable {
    
    var symbolName: String { get }
    var todoStatus: String { get }
    var inProgressStatus: String { get }
    var completedStatus: String { get }
    var progress: Float { get set }
    var totalProgress: Float { get }
    var isIndeterminate: Bool { get }
    var completed: Bool { get set }
    var inProgress: Bool { get set }
    var encounteredAnError: Bool { get set }
}

// MARK: Extension

public extension PipelineStage {
    
    // MARK: id
    
    var id: String { todoStatus }
    
    // MARK: status
    
    var status: String {
        guard !completed else { return completedStatus }
        return inProgress || encounteredAnError ? inProgressStatus : todoStatus
    }
    
    // MARK: color
    
    var color: Color {
        if completed {
            return .succcessfulActionButtonColor
        } else if encounteredAnError {
            return .red
        } else if inProgress {
            return .nordicSun
        }
        return .disabledTextColor
    }
    
    // MARK: isIndeterminate
    
    var isIndeterminate: Bool {
        totalProgress <= .leastNonzeroMagnitude
    }
    
    // MARK: update(inProgress:progressValue:)
    
    mutating func update(inProgress: Bool = false, progressValue: Float? = nil) {
        self.encounteredAnError = false
        self.inProgress = inProgress
        if let progressValue {
            self.progress = progressValue
        }
        self.completed = false
    }
    
    // MARK: complete()
    
    mutating func complete() {
        self.inProgress = false
        self.progress = totalProgress
        self.completed = true
    }
    
    // MARK: declareError()
    
    mutating func declareError() {
        guard inProgress else { return }
        inProgress = false
        encounteredAnError = true
    }
}
