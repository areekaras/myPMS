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
                        Image(systemName: "calendar")
                        Text("Planner")
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
                    PlannerView()
                }
            }
        } else {
            TabView(selection: $selectedTab) {
                ExpensesView()
                    .tag(0)
                    .tabItem {
                        Label("Expenses", systemImage: "dollarsign.circle")
                    }
                
                PlannerView()
                    .tag(1)
                    .tabItem {
                        Label("Planner", systemImage: "calendar")
                    }
            }
        }
    }
}

struct ExpensesView: View {
    var body: some View {
        NavigationStack {
            Text("Expenses")
                .navigationTitle("Expenses")
        }
    }
}

struct PlannerView: View {
    var body: some View {
        NavigationStack {
            Text("Planner")
                .navigationTitle("Planner")
        }
    }
}

#Preview {
    ContentView()
}
