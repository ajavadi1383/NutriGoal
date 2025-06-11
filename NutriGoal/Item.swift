//
//  Item.swift
//  NutriGoal
//
//  Created by Amirali Javadi on 6/7/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
} 