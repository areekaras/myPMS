import SwiftUI

struct LoginView: View {
    @ObservedObject var authManager: AuthManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Welcome to myPMS")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Please sign in to continue")
                .foregroundStyle(.secondary)
            
            Button(action: {
                Task {
                    await authManager.signInWithGoogle()
                }
            }) {
                HStack {
                    Image(systemName: "g.circle.fill")
                        .font(.title3)
                    Text("Sign in with Google")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.white)
                .foregroundColor(.black)
                .cornerRadius(8)
                .shadow(radius: 2)
            }
            .disabled(authManager.isLoading)
            
            if authManager.isLoading {
                ProgressView()
            }
            
            if let error = authManager.error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}
