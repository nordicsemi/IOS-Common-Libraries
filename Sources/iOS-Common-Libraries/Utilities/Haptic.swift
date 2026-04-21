//
//  Haptic.swift
//  nRF-Connect
//  iOSCommonLibraries
//
//  Created by Dinesh Harjani on 11/02/2019.
//  Created by Dinesh Harjani on 21/04/2026.
//  Copyright © 2026 Nordic Semiconductor. All rights reserved.
//

import UIKit

// MARK: - Haptic

struct Haptic {

    // MARK: private init

    private init() {}
    
    // MARK: Feedback
    
    enum Feedback {
        case error
        case success
        case selectionChanged
        case cancel

        // MARK: callAsFunction()
        
        @MainActor
        static let feedbackGenerator = UINotificationFeedbackGenerator()
        
        @MainActor
        static let selectionGenerator = UISelectionFeedbackGenerator()
        
        @MainActor
        fileprivate func callAsFunction() {
            switch self {
            case .error:
                Self.feedbackGenerator.prepare()
                Self.feedbackGenerator.notificationOccurred(.error)
            case .success:
                Self.feedbackGenerator.prepare()
                Self.feedbackGenerator.notificationOccurred(.success)
            case .selectionChanged:
                Self.selectionGenerator.prepare()
                Self.selectionGenerator.selectionChanged()
            case .cancel:
                Self.feedbackGenerator.prepare()
                Self.feedbackGenerator.notificationOccurred(.warning)
            }
        }
    }

    // MARK: generate
    
    nonisolated
    static func generate(feedbackFor feedback: Haptic.Feedback) {
        Task { @MainActor in
            feedback()
        }
    }
}
