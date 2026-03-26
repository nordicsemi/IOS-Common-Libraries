//
//  DevZoneLinkView.swift
//  iOSCommonLibraries
//
//  Created by Dinesh Harjani on 8/7/25.
//  Copyright © 2025 Nordic Semiconductor. All rights reserved.
//

import SwiftUI

// MARK: - DevZoneLinkView

@available(iOS 14.0, macCatalyst 14.0, macOS 11.0, *)
public struct DevZoneLinkView: View {
    
    // MARK: init
    
    public init() {}
    
    // MARK: view
    
    public var body: some View {
        Link(destination: URL(string: "https://devzone.nordicsemi.com/")!) {
            Label("Help (Nordic DevZone)", systemImage: "lifepreserver")
        }
    }
}
