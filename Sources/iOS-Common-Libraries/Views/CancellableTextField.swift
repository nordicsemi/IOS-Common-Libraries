//
//  CancellableTextField.swift
//  nRF-Connect
//  iOSCommonLibraries
//
//  Created by Dinesh Harjani on 29/9/23.
//  Copyright © 2023 Nordic Semiconductor. All rights reserved.
//

import SwiftUI

// MARK: - CancellableTextField

/**
 Stolen from: https://www.appcoda.com/swiftui-search-bar/
 */
@available(iOS 15.0, macCatalyst 15.0, macOS 12.0, *)
public struct CancellableTextField: View {
    
    // MARK: Icon
    
    public enum Icon {
        case search, text
        
        var sfSymbolName: String {
            switch self {
            case .search:
                return "magnifyingglass"
            case .text:
                return "character.cursor.ibeam"
            }
        }
    }
    
    // MARK: Private Properties
    
    private let emptyText: String
    private let cancelText: String
    private let icon: Icon
    
    @Binding private var text: String
    @State private var isEditing: Bool
    @FocusState private var isTextFieldInFocus: Bool
    
    // MARK: Init
    
    public init(_ emptyText: String, cancelText: String, icon: Icon, text: Binding<String>) {
        self.emptyText = emptyText
        self.cancelText = cancelText
        self.icon = icon
        self._text = text
        self.isEditing = false
    }
    
    // MARK: body
    
    public var body: some View {
        HStack {
            HStack {
                Image(systemName: icon.sfSymbolName)
                    .foregroundColor(.nordicMiddleGrey)
                    .padding(.leading, 8)
                
                // onEditingChanged's parameter returns whether TextField is in focus or not
                TextField(emptyText, text: $text, onEditingChanged: { _ in
                    withAnimation {
                        // Assume if text changed, user is editing.
                        isEditing = true
                    }
                })
                .padding(.vertical, 8)
                .focused($isTextFieldInFocus)
                .onChange(of: isTextFieldInFocus) { inFocus in
                    // Set 'isEditing' to false if it's set to true but focus changed to 'false'.
                    // Example: Dismissing keyboard with 'submit' button.
                    guard isEditing, !inFocus else { return }
                    withAnimation {
                        isEditing = false
                    }
                }
                
                if isEditing {
                    Button {
                        withAnimation {
                            self.text = ""
                            // Button action will make TextField lose focus via SwiftUI,
                            // so we restore it by force.
                            isTextFieldInFocus = true
                        }
                    } label: {
                        Image(systemName: "multiply.circle.fill")
                            .foregroundColor(.nordicMiddleGrey)
                    }
                    .buttonStyle(.borderless)
                    .frame(width: 44)
                    .padding(4)
                }
            }
            #if os(iOS) || targetEnvironment(macCatalyst)
            .background(Color(.systemGray6))
            #else
            .background(Color(.controlBackgroundColor))
            #endif
            .cornerRadius(8)
            
            if isEditing {
                Button("Cancel") {
                    withAnimation {
                        // This makes isEditing true via onEditingChanged()
                        text = cancelText
                        // Then, we set isEditing to false and return focus.
                        isEditing = false
                        isTextFieldInFocus = false
                    }
                }
                .tint(.universalAccentColor)
                .buttonStyle(.borderless)
                .padding(4)
                .transition(.move(edge: .trailing))
            }
        }
    }
}
