//
//  ContentView.swift
//  EventKitDemo
//
//  Created by xiaopin on 2025/4/30.
//

import SwiftUI
import EventKit

struct ContentView: View {
    @State private var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @State private var reminderTitle: String = ""
    private let eventReminder = EventReminder()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            Text("Authorization Status: \(authorizationStatusText)")
                .padding()
            
            Button(action: requestAccess) {
                Text("Request Access")
            }
            .padding()
            
            TextField("Reminder Title", text: $reminderTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: addReminder) {
                Text("Add Reminder")
            }
            .padding()
        }
        .padding()
        .onAppear {
            checkAuthorizationStatus()
        }
    }
    
    private var authorizationStatusText: String {
        switch authorizationStatus {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        case .fullAccess:
            return "fullAccess"
        case .writeOnly:
            return "writeOnly"
        @unknown default: return "Unknown"
        }
    }
    
    private func checkAuthorizationStatus() {
        authorizationStatus = eventReminder.getAuthorizationStatus()
    }
    
    private func requestAccess() {
        eventReminder.requestAccess { granted, error in
            DispatchQueue.main.async {
                checkAuthorizationStatus()
                if let error = error {
                    print("Error requesting access: \(error.localizedDescription)")
                } else {
                    print("Access granted: \(granted)")
                }
            }
        }
    }
    
    private func addReminder() {
        guard authorizationStatus == .authorized || authorizationStatus == .fullAccess || authorizationStatus == .writeOnly else {
            print("Access not authorized")
            return
        }
        // 设置下午3点提醒
        let date = Calendar.current.date(bySettingHour: 17, minute: 31, second: 0, of: Date())!
        eventReminder.addReminder(title: reminderTitle, notes: "测试", dueDate: date){ success, error in
            if success {
                print("Reminder added successfully")
            } else if let error = error {
                print("Error adding reminder: \(error.localizedDescription)")
            }
        }
    }
}


#Preview {
    ContentView()
}
