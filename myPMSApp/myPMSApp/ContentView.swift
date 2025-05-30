import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showLogoutAlert = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        Group {
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
                            Image(systemName: "list.bullet")
                            Text("Backlogs")
                        }
                        .foregroundColor(selectedTab == 1 ? .accentColor : .primary)
                        .onTapGesture { selectedTab = 1 }
                        
                        HStack {
                            Image(systemName: "lightbulb")
                            Text("Ideas")
                        }
                        .foregroundColor(selectedTab == 2 ? .accentColor : .primary)
                        .onTapGesture { selectedTab = 2 }
                        
                        Spacer()
                        
                        Button(action: {
                            showLogoutAlert = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Logout")
                            }
                        }
                    }
                    .padding()
                } detail: {
                    if selectedTab == 0 {
                        ExpensesView()
                    } else if selectedTab == 1 {
                        BacklogView()
                    } else {
                        IdeasView()
                    }
                }
            } else {
                NavigationStack {
                    TabView(selection: $selectedTab) {
                        ExpensesView()
                            .tag(0)
                            .tabItem {
                                Label("Expenses", systemImage: "dollarsign.circle")
                            }
                        
                        BacklogView()
                            .tag(1)
                            .tabItem {
                                Label("Backlogs", systemImage: "list.bullet")
                            }
                        
                        IdeasView()
                            .tag(2)
                            .tabItem {
                                Label("Ideas", systemImage: "lightbulb")
                            }
                    }
                }
                .safeAreaInset(edge: .top) {
                    HStack {
                        Spacer()
                        Button(action: {
                            showLogoutAlert = true
                        }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                        .padding()
                    }
                }
            }
        }
        .alert("Sign Out", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                Task {
                    await authManager.signOut()
                }
            }
        } message: {
            Text("Are you sure you want to sign out?")
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
