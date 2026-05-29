//
//  AutoLayout.swift
//  nRF-Connect
//  iOSCommonLibraries
//
//  Created by Dinesh Harjani on 17/12/2018.
//  Created by Dinesh Harjani on 29/05/2026.
//  Copyright © 2026 Nordic Semiconductor. All rights reserved.
//

import UIKit

// MARK: - Safe Anchor(s)

public extension UIView {

    var safeTopAnchor: NSLayoutYAxisAnchor {
        safeAreaLayoutGuide.topAnchor
    }

    var safeLeadingAnchor: NSLayoutXAxisAnchor {
        safeAreaLayoutGuide.leadingAnchor
    }

    var safeTrailingAnchor: NSLayoutXAxisAnchor {
        safeAreaLayoutGuide.trailingAnchor
    }

    var safeWidthAnchor: NSLayoutDimension {
        safeAreaLayoutGuide.widthAnchor
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        safeAreaLayoutGuide.bottomAnchor
    }
    
    var safeHeightAnchor: NSLayoutDimension {
        safeAreaLayoutGuide.heightAnchor
    }
}

// MARK: - addForAutoLayout()

public extension UIView {

    /**
     Adds all subviews to the current `UIView`, but also sets ``translatesAutoresizingMaskIntoConstraints``
     for every added subview to `false`. This is because by default it's set to `true`, which means
     "Springs and Struts" behaviour via automatic constraints. That's why we turn it off.
     */
    func addForAutoLayout(subviews: [UIView]) {
        subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
}

// MARK: - Sequence

public extension Sequence where Element == NSLayoutConstraint {
    
    func activateAll() {
        forEach { $0.isActive = true }
    }
    
    func deactivateAll() {
        forEach { $0.isActive = false }
    }
}
