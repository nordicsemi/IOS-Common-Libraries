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
    
    public typealias OnChange = (T) -> Void
    
    // MARK: Properties
    
    private let title: String
    private let systemImage: String?
    private let selectedValue: Binding<T>
    private let possibleValues: [T]
    // TODO: Remove onChange because it breaks SwiftUI comparison, causing it to make unnecessary layouts when nothing else has changed.
    private let onChange: OnChange?
    
    // MARK: Init
    
    public init(title: String, systemImage: String? = nil, selectedValue: Binding<T>,
                possibleValues: [T], onChange: OnChange? = nil) {
        self.title = title
        self.systemImage = systemImage
        self.selectedValue = selectedValue
        self.possibleValues = possibleValues
        self.onChange = onChange
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
            .onChange(of: selectedValue.wrappedValue, perform: { newValue in
                onChange?(newValue)
            })
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
    
    init(title: String, systemImage: String? = nil, selectedValue: Binding<T>, 
         onChange: InlinePicker.OnChange? = nil) {
        self.init(title: title, systemImage: systemImage, selectedValue: selectedValue,
                  possibleValues: T.allCases, onChange: onChange)
    }
}
