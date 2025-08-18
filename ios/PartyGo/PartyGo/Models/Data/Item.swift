//
//  Item.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/18.
//

import Foundation
import SwiftData

// Swift6 改进的数据模型
@Model
final class Item {
    // Swift6 新的属性包装器
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var title: String
    var isCompleted: Bool
    
    init(title: String, timestamp: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.timestamp = timestamp
        self.isCompleted = false
    }
}

// Swift6 新的扩展语法
extension Item {
    var formattedDate: String {
        timestamp.formatted(date: .abbreviated, time: .shortened)
    }
}
