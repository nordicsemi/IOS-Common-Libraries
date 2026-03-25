//
//  LabelStyle.swift
//  iOS-Common-Libraries
//
//  Created by Dinesh Harjani on 15/5/24.
//  Copyright © 2024 Nordic Semiconductor. All rights reserved.
//

import SwiftUI

// MARK: - ColorIconOnlyLabelStyle

@available(iOS 14.0, macCatalyst 14.0, macOS 11.0, *)
public struct ColorIconOnlyLabelStyle: LabelStyle {
    
    let iconColor: Color
    
    @Environment(\.isEnabled) private var isEnabled
    
    public func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline) {
            configuration.icon
                .foregroundColor(isEnabled ? iconColor : .disabledTextColor)
            
            configuration.title
        }
    }
}

// MARK: - LabelStyle

@available(iOS 14.0, macCatalyst 14.0, macOS 11.0, *)
public extension LabelStyle where Self == ColorIconOnlyLabelStyle {
    
    static func colorIconOnly(_ color: Color) -> ColorIconOnlyLabelStyle {
        return ColorIconOnlyLabelStyle(iconColor: color)
    }
}
