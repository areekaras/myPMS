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
            .task {
                for await state in supabase.auth.authStateChanges {
                    if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                        authManager.isAuthenticated = state.session != nil
                    }
                }
            }
        }
    }
}
