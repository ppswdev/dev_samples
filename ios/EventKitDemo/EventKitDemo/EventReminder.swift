//
//  EventReminder.swift
//  EventKitDemo
//
//  Created by xiaopin on 2025/4/30.
//

import Foundation
import EventKit

class EventReminder {
    private let eventStore = EKEventStore()
    
    // 获取授权状态
    func getAuthorizationStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: .reminder)
    }
    
    // 请求授权
    func requestAccess(completion: @escaping (Bool, Error?) -> Void) {
        eventStore.requestAccess(to: .reminder) { granted, error in
            completion(granted, error)
        }
    }
    
    // 添加提醒
    func addReminder(title: String, notes: String?, dueDate: Date, completion: @escaping (Bool, Error?) -> Void) {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = notes
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        
        let alarm = EKAlarm(absoluteDate: dueDate)
        reminder.addAlarm(alarm)
        
        do {
            try eventStore.save(reminder, commit: true)
            completion(true, nil)
        } catch {
            completion(false, error)
        }
    }
}
