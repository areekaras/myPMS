import SwiftUI

struct BacklogView: View {
    @StateObject private var backlogManager = BacklogManager(client: supabase)
    @State private var showingAddForm = false
    @State private var selectedBacklogForEdit: Backlog?
    
    var body: some View {
        NavigationStack {
            Group {
                if backlogManager.isLoading {
                    ProgressView()
                } else if let error = backlogManager.error {
                    ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(error))
                } else if backlogManager.backlogs.isEmpty {
                    ContentUnavailableView("No Backlogs Yet", systemImage: "list.bullet", description: Text("Tap + to add a new backlog item"))
                } else {
                    List {
                        ForEach(backlogManager.backlogs) { backlog in
                            BacklogRowView(backlog: backlog)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        Task {
                                            try? await backlogManager.deleteBacklog(backlog)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        selectedBacklogForEdit = backlog
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                }
            }
            .navigationTitle("Backlogs")
            .toolbar {
                Button {
                    showingAddForm = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddForm) {
                AddBacklogForm(backlogManager: backlogManager)
            }
            .sheet(item: $selectedBacklogForEdit) { backlog in
                AddBacklogForm(backlogManager: backlogManager, backlogToEdit: backlog)
            }
            .task {
                await backlogManager.fetchBacklogs()
            }
        }
    }
}

struct BacklogRowView: View {
    let backlog: Backlog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(backlog.title)
                    .font(.headline)
                Spacer()
                Text(backlog.status.rawValue.capitalized)
                    .font(.caption)
                    .padding(4)
                    .background(backlog.status.color.opacity(0.2))
                    .foregroundColor(backlog.status.color)
                    .cornerRadius(4)
            }
            
            if let description = backlog.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Label("Priority: \(backlog.priority)", systemImage: "flag.fill")
                    .font(.caption)
                    .padding(4)
                    .background(.gray.opacity(0.2))
                    .cornerRadius(4)
                
                if let effort = backlog.estimatedEffort {
                    Label(String(format: "Effort: %.1f", effort), systemImage: "clock.fill")
                        .font(.caption)
                        .padding(4)
                        .background(.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
            }
            
            Text("Updated: \(backlog.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}
