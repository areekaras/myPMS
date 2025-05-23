//
//  myPMSAppApp.swift
//  myPMSApp
//
//  Created by Shibili Areekara on 18/05/25.
//

import SwiftUI

@main
struct myPMSAppApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var expenseTracker = ExpenseTracker()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    ContentView()
                        .environmentObject(expenseTracker)
                } else {
                    ProgressView("Authenticating...")
                        .task {
                            do {
                                try await authManager.signInAnonymously()
                            } catch {
                                print("Auth error:", error)
                            }
                        }
                }
            }
        }
    }
}
