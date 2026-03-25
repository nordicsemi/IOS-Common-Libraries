//
//  SourceCodeLinkView.swift
//  iOSCommonLibraries
//
//  Created by Dinesh Harjani on 8/7/25.
//  Copyright © 2025 Nordic Semiconductor. All rights reserved.
//

import SwiftUI

// MARK: - SourceCodeLinkView

@available(iOS 14.0, macCatalyst 14.0, macOS 11.0, *)
public struct SourceCodeLinkView: View {
    
    // MARK: Private Properties
    
    private let text: String
    private let url: URL
    
    // MARK: init
    
    public init(_ text: String = "Source Code (GitHub)", url: URL) {
        self.text = text
        self.url = url
    }
    
    // MARK: view
    
    public var body: some View {
        Link(destination: url) {
            Label(text, systemImage: "keyboard")
        }
    }
}
