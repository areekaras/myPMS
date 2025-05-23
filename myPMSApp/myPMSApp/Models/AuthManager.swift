import SwiftUI
import Supabase

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    
    func signInAnonymously() async throws {
        let session = try await supabase.auth.signIn(
            email: "anonymous@user.com",
            password: "anonymous123"
        )
        
        await MainActor.run {
            self.isAuthenticated = true
        }
    }
}
