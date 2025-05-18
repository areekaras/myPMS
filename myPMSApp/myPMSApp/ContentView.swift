import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        #if os(macOS)
        NavigationSplitView {
            List(selection: $selectedTab) {
                Label("Expenses", systemImage: "dollarsign.circle")
                    .tag(0)
                Label("Planner", systemImage: "calendar")
                    .tag(1)
            }
            .listStyle(.sidebar)
        } detail: {
            tabContent
        }
        #else
        TabView(selection: $selectedTab) {
            tabContent
        }
        #endif
    }
    
    @ViewBuilder
    private var tabContent: some View {
        Group {
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
