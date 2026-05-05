//
//  InlinePicker.swift
//  nRF-Connect
//  iOS-Common-Libraries
//
//  Created by Dinesh Harjani on 13/3/23.
//  Copyright © 2023 Nordic Semiconductor. All rights reserved.
//

import SwiftUI

// MARK: - InlinePicker

@available(iOS 16.0, macCatalyst 16.0, macOS 13.0, *)
public struct InlinePicker<T: Hashable & Equatable>: View {
    
    // MARK: Properties
    
    private let title: String
    private let systemImage: String?
    private let selectedValue: Binding<T>
    private let possibleValues: [T]
    
    // MARK: Init
    
    public init(title: String, systemImage: String? = nil, selectedValue: Binding<T>,
                possibleValues: [T]) {
        self.title = title
        self.systemImage = systemImage
        self.selectedValue = selectedValue
        self.possibleValues = possibleValues
    }
    
    // MARK: View
    
    public var body: some View {
        LabeledContent {
            Picker("", selection: selectedValue) {
                ForEach(possibleValues, id: \.self) { value in
                    Text((value as? CustomStringConvertible)?.description ?? (value as? CustomDebugStringConvertible)?.debugDescription ?? "nil")
                        .tag(value)
                }
            }
            .pickerStyle(.menu)
        } label: {
            if let systemImage {
                Label(title, systemImage: systemImage)
            } else {
                Text(title)
            }
        }
    }
}

// MARK: - CaseIterable

@available(iOS 16.0, macCatalyst 16.0, macOS 13.0, *)
public extension InlinePicker where T: CaseIterable, T.AllCases == [T] {
    
    init(title: String, systemImage: String? = nil, selectedValue: Binding<T>) {
        self.init(title: title, systemImage: systemImage, selectedValue: selectedValue,
                  possibleValues: T.allCases)
    }
}
