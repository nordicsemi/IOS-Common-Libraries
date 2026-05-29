//
//  UIStackView.swift
//  nRF-Connect
//  iOSCommonLibraries
//
//  Created by Dinesh Harjani on 27/04/2020.
//  Created by Dinesh Harjani on 29/05/2026.
//  Copyright © 2026 Nordic Semiconductor. All rights reserved.
//

import UIKit

// MARK: - UIStackView

public extension UIStackView {
    
    static func inColumns(_ columns: UIView..., distribution: Distribution = .fill, alignment: Alignment = .fill, spacing: CGFloat = 8.0) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = distribution
        stackView.alignment = alignment
        stackView.spacing = spacing
        
        columns.forEach { column in
            stackView.addArrangedSubview(column)
        }
        columns.first?.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return stackView
    }
    
    static func inRows(_ rows: UIView..., alignment: Alignment = .fill, spacing: CGFloat = 8.0) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = alignment
        stackView.spacing = spacing
        rows.forEach { row in
            stackView.addArrangedSubview(row)
        }
        return stackView
    }
}
