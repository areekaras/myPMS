import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        if horizontalSizeClass == .regular {
            NavigationSplitView {
                // Sidebar content
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "dollarsign.circle")
                        Text("Expenses")
                    }
                    .foregroundColor(selectedTab == 0 ? .accentColor : .primary)
                    .onTapGesture { selectedTab = 0 }
                    
                    HStack {
                        Image(systemName: "lightbulb")
                        Text("Ideas")
                    }
                    .foregroundColor(selectedTab == 1 ? .accentColor : .primary)
                    .onTapGesture { selectedTab = 1 }
                    
                    Spacer()
                }
                .padding()
            } detail: {
                if selectedTab == 0 {
                    ExpensesView()
                } else {
                    IdeasView()
                }
            }
        } else {
            TabView(selection: $selectedTab) {
                ExpensesView()
                    .tag(0)
                    .tabItem {
                        Label("Expenses", systemImage: "dollarsign.circle")
                    }
                
                IdeasView()
                    .tag(1)
                    .tabItem {
                        Label("Ideas", systemImage: "lightbulb")
                    }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Task {
                            await authManager.signOut()
                        }
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
        }
    }
}

struct ExpensesView: View {
    @StateObject private var tracker = ExpenseTracker()
    
    var body: some View {
        NavigationStack {
            ExpenseListView(tracker: tracker)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ExpenseTracker())
        .environmentObject(AuthManager())
}
