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
                        .environmentObject(authManager)
                } else {
                    LoginView(authManager: authManager)
                }
            }
            .onOpenURL { url in
                // Handle OAuth callback
                Task {
                    do {
                        try await supabase.auth.session(from: url)
                    } catch {
                        print("OAuth callback error:", error)
                    }
                }
            }
            .task {
                // Check for existing session on launch
                do {
                    if try await supabase.auth.session != nil {
                        await MainActor.run {
                            authManager.isAuthenticated = true
                        }
                    }
                } catch {
                    print("Session check error:", error)
                }
            }
        }
    }
}
