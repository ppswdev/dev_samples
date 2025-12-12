//
//  StoreKit2App.swift
//  StoreKit2
//
//  Created by Jordan Calhoun on 8/28/23.
//

import SwiftUI

@main
struct StoreKit2App: App {
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            if #available(iOS 17.0, *) {
                StoreExampleView()
                    .onChange(of: scenePhase) { oldPhase, newPhase in
                        if newPhase == .active && oldPhase != .active {
                            // 应用回到前台
                            handleAppBecomeActive()
                        }
                    }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    private func handleAppBecomeActive() {
        Task {
            await StoreKit2Manager.shared.checkSubscriptionStatus()
        }
    }
}
