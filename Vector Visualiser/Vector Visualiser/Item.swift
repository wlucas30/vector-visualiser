//
//  Item.swift
//  Vector Visualiser
//
//  Created by Will Lucas on 16/06/2024.
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
