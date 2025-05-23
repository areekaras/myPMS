import SwiftUI
import Supabase

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    
    func signInWithGoogle() async {
        isLoading = true
        error = nil
        
        do {
            try await supabase.auth.signInWithOAuth(
                provider: .google,
                redirectTo: AppEnvironment.googleCallbackUrlString
            )
            await MainActor.run {
                self.isAuthenticated = true
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func signOut() async {
        isLoading = true
        do {
            try await supabase.auth.signOut()
            await MainActor.run {
                self.isAuthenticated = false
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
