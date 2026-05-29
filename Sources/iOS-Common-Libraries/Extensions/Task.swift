//
//  Task.swift
//  IOS-Common-Libraries
//
//  Created by Dinesh Harjani on 8/7/25.
//  Copyright © 2025 Nordic Semiconductor. All rights reserved.
//

import Foundation
import Combine

/**
 Helps integrate Task(s) into Combine's Cancellables to aid in Task management.
 
 Source: https://www.donnywals.com/comparing-lifecycle-management-for-async-sequences-and-publishers/
 */
public extension Task {
    
    func store(in cancellables: inout Set<AnyCancellable>) {
        asCancellable()
            .store(in: &cancellables)
    }

    func asCancellable() -> AnyCancellable {
        .init {
            self.cancel()
        }
    }
}
