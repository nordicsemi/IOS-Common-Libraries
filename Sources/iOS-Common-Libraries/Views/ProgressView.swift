//
//  ProgressView.swift
//  iOSCommonLibraries
//
//  Created by Dinesh Harjani on 17/12/24.
//  Copyright © 2024 Nordic Semiconductor. All rights reserved.
//

import SwiftUI

// MARK: - ProgressView

@available(iOS 14.0, macCatalyst 14.0, macOS 11.0, *)
public extension ProgressView {

    func fixedCircularProgressView() -> some View {
        self
            .progressViewStyle(.circular)
            .id(UUID())
    }
}
